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

// CardNexus credentials render into the backend only, from the secrets
// variable, and render empty (CardNexus stays off) until installed.
func TestCardNexusBackendSecrets(t *testing.T) {
	source, err := os.ReadFile(filepath.Join("..", "..", "infra", "jobs", "tcg-medusa.nomad.template"))
	if err != nil { t.Fatal(err) }
	lines := regexp.MustCompile(`(?m)^CARDNEXUS_[A-Z_]+=.*$`).FindAll(source, -1)
	if len(lines) != 2 { t.Fatalf("expected exactly two backend mappings, got %d", len(lines)) }
	for _, configured := range []bool{false, true} {
		items := map[string]nomadVarItem{}
		if configured {
			for key, value := range map[string]string{"cardnexus_api_key": "fixture-only", "cardnexus_webhook_secret": "fixture-secret"} {
				items[key] = nomadVarItem{Key: key, Value: value}
			}
		}
		for _, line := range lines {
			tmpl, err := template.New("cardnexus").Funcs(template.FuncMap{"nomadVar": func(path string) map[string]nomadVarItem {
				if path != "TCG_MEDUSA_VAR_PATH_PLACEHOLDER/secrets" { t.Fatalf("unexpected secret scope: %s", path) }
				return items
			}}).Parse(string(line))
			if err != nil { t.Fatal(err) }
			var output bytes.Buffer
			if err := tmpl.Execute(&output, nil); err != nil { t.Fatal(err) }
			name := strings.SplitN(string(line), "=", 2)[0]
			value := ""
			if configured { value = items[strings.ToLower(name)].Value }
			if output.String() != name+"=\""+value+"\"" { t.Fatalf("unexpected render for %s: %s", name, output.String()) }
		}
	}
	storefront := strings.SplitN(string(source), `task "storefront"`, 2)[1]
	if strings.Contains(storefront, "CARDNEXUS_") { t.Fatal("CardNexus credentials must not enter the storefront") }
}
