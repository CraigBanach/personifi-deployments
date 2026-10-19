package templates_test

import (
	"bytes"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"text/template"
)

// Nomad exposes item values as wrapper structs with a Value field and String
// method. Even an absent map key returns a truthy zero struct, not an empty string.
type nomadVarItem struct{ Key, Value string }

func (item nomadVarItem) String() string { return item.Value }

func TestNativeRuntimeTemplates(t *testing.T) {
	source, err := os.ReadFile(filepath.Join("..", "..", "infra", "jobs", "tcg-medusa.nomad.template"))
	if err != nil {
		t.Fatal(err)
	}
	blocks := regexp.MustCompile(`(?s)template\s*\{\s*data\s*=\s*<<EOF\r?\n(.*?)\r?\nEOF\s*destination\s*=\s*"([^"]+)"`).FindAllSubmatch(source, -1)
	templates := map[string]string{}
	for _, block := range blocks {
		templates[string(block[2])] = string(block[1])
	}
	for _, test := range []struct {
		name    string
		exists  bool
		items   map[string]string
		mode    string
		enabled string
		json    string
	}{
		{"absent", false, nil, "disabled", "false", "{}"},
		{"cardtrader_explicit", true, map[string]string{"channel_sync_cardtrader_listings_enabled": "true", "channel_sync_attachment_settlements_enabled": "true",
			"channel_sync_attachment_shipping_option_id": "so_reviewed", "channel_sync_attachment_location_id": "sloc_reviewed"}, "disabled", "false", "{}"},
		{"empty", true, map[string]string{}, "disabled", "false", "{}"},
		{"staged", true, map[string]string{"channel_sync_ebay_runtime_json": `{"synthetic":true}`}, "disabled", "false", `{"synthetic":true}`},
		{"chunked", true, map[string]string{"channel_sync_ebay_runtime_parts": "test/runtime-0,test/runtime-1", "channel_sync_ebay_runtime_json": `{"ignored":true}`}, "disabled", "false", `{"synthetic":true}`},
		{"explicit_active", true, map[string]string{"channel_sync_mode": "active", "channel_sync_ebay_runtime_enabled": "true", "channel_sync_ebay_runtime_json": `{"synthetic":true}`}, "active", "true", `{"synthetic":true}`},
		{"postgres", true, map[string]string{"channel_sync_mode": "active", "channel_sync_ebay_runtime_enabled": "false", "channel_sync_ebay_runtime_source": "postgres", "channel_sync_ebay_runtime_connection_id": "reviewed-account", "channel_sync_ebay_runtime_parts": "must-not-be-read"}, "active", "false", `{}`},
		{"listings_active", true, map[string]string{"channel_sync_mode": "active", "channel_sync_ebay_runtime_enabled": "true", "channel_sync_ebay_runtime_source": "postgres", "channel_sync_ebay_runtime_connection_id": "reviewed-account", "channel_sync_ebay_listings_enabled": "true", "channel_sync_ebay_listings_connection_id": "reviewed-account"}, "active", "true", `{}`},
	} {
		t.Run(test.name, func(t *testing.T) {
			functions := template.FuncMap{
				"split": func(separator, value string) []string { return strings.Split(value, separator) },
				"nomadVarExists": func(path string) bool {
					if !strings.HasSuffix(path, "/channel-sync") {
						t.Fatalf("unexpected variable scope: %s", path)
					}
					return test.exists
				},
				"nomadVar": func(path string) map[string]nomadVarItem {
					if !test.exists {
						t.Fatal("absent variable must not be fetched or block rendering")
					}
					if strings.HasSuffix(path, "/channel-sync") {
						items := map[string]nomadVarItem{}
						for key, value := range test.items {
							items[key] = nomadVarItem{Key: key, Value: value}
						}
						return items
					}
					parts := map[string]string{"test/runtime-0": `{"synthetic":`, "test/runtime-1": `true}`}
					part, exists := parts[path]
					if !exists {
						t.Fatalf("unreviewed manifest part: %s", path)
					}
					return map[string]nomadVarItem{"json_part": {Key: "json_part", Value: part}}
				},
			}
			render := func(destination string) string {
				body, exists := templates[destination]
				if !exists {
					t.Fatalf("missing template: %s", destination)
				}
				parsed, err := template.New(destination).Funcs(functions).Parse(body)
				if err != nil {
					t.Fatal(err)
				}
				var output bytes.Buffer
				if err := parsed.Execute(&output, nil); err != nil {
					t.Fatal(err)
				}
				return output.String()
			}
			env := render("secrets/channel-sync.env")
			// CardTrader and attachment switches stay off and dispatch IDs empty
			// unless each one is explicitly set; nothing inherits from eBay keys.
			for _, name := range []string{"CARDTRADER_OBSERVATION", "CARDTRADER_LISTINGS", "CARDTRADER_ORDERS", "CARDTRADER_NATIVE_ORDERS", "CARDTRADER_INTAKE",
				"CARDTRADER_SHIPMENTS", "ATTACHMENT_BINDINGS", "ATTACHMENT_NATIVE_FENCE", "ATTACHMENT_FINANCIAL_CREATION", "ATTACHMENT_PLUGIN_PICKS", "ATTACHMENT_SETTLEMENTS"} {
				want := "false"
				if value, set := test.items["channel_sync_"+strings.ToLower(name)+"_enabled"]; set {
					want = value
				}
				if expected := `CHANNEL_SYNC_` + name + `_ENABLED="` + want + `"`; !strings.Contains(env, expected) {
					t.Fatalf("CardTrader switch must default off and be explicit: %s", expected)
				}
			}
			for _, name := range []string{"ATTACHMENT_SHIPPING_OPTION_ID", "ATTACHMENT_LOCATION_ID"} {
				if expected := `CHANNEL_SYNC_` + name + `="` + test.items["channel_sync_"+strings.ToLower(name)] + `"`; !strings.Contains(env, expected) {
					t.Fatalf("CardTrader dispatch identity must be explicit: %s", expected)
				}
			}
			listingEnabled, listingConnection := "false", ""
			if test.name == "listings_active" {
				listingEnabled, listingConnection = "true", "reviewed-account"
			}
			for _, expected := range []string{`CHANNEL_SYNC_EBAY_LISTINGS_ENABLED="` + listingEnabled + `"`, `CHANNEL_SYNC_EBAY_LISTINGS_SOURCE="postgres"`, `CHANNEL_SYNC_EBAY_LISTINGS_CONNECTION_ID="` + listingConnection + `"`} {
				if !strings.Contains(env, expected) {
					t.Fatalf("listing activation must remain explicit, account-pinned and Postgres-only: %s", expected)
				}
			}
			if test.name == "postgres" && (!strings.Contains(env, `CHANNEL_SYNC_EBAY_RUNTIME_SOURCE="postgres"`) || !strings.Contains(env, `CHANNEL_SYNC_EBAY_RUNTIME_CONNECTION_ID="reviewed-account"`)) {
				t.Fatal("Postgres mode must pin the explicit account without a manifest dependency")
			}
			for _, expected := range []string{
				`CHANNEL_SYNC_MODE="` + test.mode + `"`,
				`CHANNEL_SYNC_EBAY_RUNTIME_ENABLED="` + test.enabled + `"`,
				`CHANNEL_SYNC_EBAY_RUNTIME_FILE="/secrets/ebay-native-runtime.json"`,
			} {
				if !strings.Contains(env, expected) {
					t.Fatalf("missing environment setting: %s", expected)
				}
			}
			if got := strings.TrimSpace(render("secrets/ebay-native-runtime.json")); got != test.json {
				t.Fatalf("private manifest mismatch: %s", got)
			}
			if test.name == "chunked" {
				broken := strings.ReplaceAll(templates["secrets/ebay-native-runtime.json"], `split "," (index . "channel_sync_ebay_runtime_parts").Value`, `split "," (index . "channel_sync_ebay_runtime_parts")`)
				parsed, err := template.New("regression").Funcs(functions).Parse(broken)
				if err != nil {
					t.Fatal(err)
				}
				var output bytes.Buffer
				if err := parsed.Execute(&output, nil); err == nil || !strings.Contains(err.Error(), "expected string") {
					t.Fatalf("regression must reproduce Nomad's typed-value rejection: %v", err)
				}
			}
		})
	}
	for _, destination := range []string{"secrets/channel-sync.env", "secrets/ebay-native-runtime.json"} {
		pattern := `(?s)destination\s*=\s*"` + regexp.QuoteMeta(destination) + `"[^}]*perms\s*=\s*"0600"[^}]*change_mode\s*=\s*"restart"`
		if !regexp.MustCompile(pattern).Match(source) {
			t.Fatalf("private permissions/restart contract missing: %s", destination)
		}
	}
	// The backend image runs as the non-root node user. Root-owned 0600
	// manifests render successfully but stop the worker with EACCES.
	if !regexp.MustCompile(`(?s)destination\s*=\s*"secrets/ebay-native-runtime.json"[^}]*uid\s*=\s*1000[^}]*gid\s*=\s*1000`).Match(source) {
		t.Fatal("runtime manifest must remain private and readable by backend UID/GID 1000")
	}
}
