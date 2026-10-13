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
		{"empty", true, map[string]string{}, "disabled", "false", "{}"},
		{"staged", true, map[string]string{"channel_sync_ebay_runtime_json": `{"synthetic":true}`}, "disabled", "false", `{"synthetic":true}`},
		{"chunked", true, map[string]string{"channel_sync_ebay_runtime_parts": "test/runtime-0,test/runtime-1", "channel_sync_ebay_runtime_json": `{"ignored":true}`}, "disabled", "false", `{"synthetic":true}`},
		{"explicit_active", true, map[string]string{"channel_sync_mode": "active", "channel_sync_ebay_runtime_enabled": "true", "channel_sync_ebay_runtime_json": `{"synthetic":true}`}, "active", "true", `{"synthetic":true}`},
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
				"nomadVar": func(path string) map[string]string {
					if !test.exists {
						t.Fatal("absent variable must not be fetched or block rendering")
					}
					if strings.HasSuffix(path, "/channel-sync") {
						return test.items
					}
					parts := map[string]string{"test/runtime-0": `{"synthetic":`, "test/runtime-1": `true}`}
					part, exists := parts[path]
					if !exists {
						t.Fatalf("unreviewed manifest part: %s", path)
					}
					return map[string]string{"json_part": part}
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
		})
	}
	for _, destination := range []string{"secrets/channel-sync.env", "secrets/ebay-native-runtime.json"} {
		pattern := `(?s)destination\s*=\s*"` + regexp.QuoteMeta(destination) + `"[^}]*perms\s*=\s*"0600"[^}]*change_mode\s*=\s*"restart"`
		if !regexp.MustCompile(pattern).Match(source) {
			t.Fatalf("private permissions/restart contract missing: %s", destination)
		}
	}
}
