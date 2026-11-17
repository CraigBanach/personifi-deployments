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

func TestAlertEmailBackendSecrets(t *testing.T) {
	source, err := os.ReadFile(filepath.Join("..", "..", "infra", "jobs", "tcg-medusa.nomad.template"))
	if err != nil { t.Fatal(err) }
	source = bytes.ReplaceAll(source, []byte("\r\n"), []byte("\n"))
	lines := regexp.MustCompile(`(?m)^[A-Z_]+_ALERT_TO_EMAIL=.*$`).FindAll(source, -1)
	if len(lines) != 2 { t.Fatalf("expected exactly two alert email mappings, got %d", len(lines)) }
	for _, configured := range []bool{false, true} {
		items := map[string]nomadVarItem{}
		if configured {
			for _, key := range []string{"cardmarket_alert_to_email", "payment_alert_to_email"} {
				items[key] = nomadVarItem{Key: key, Value: "ops@example.test"}
			}
		}
		for _, line := range lines {
			tmpl, err := template.New("alert").Funcs(template.FuncMap{"nomadVar": func(path string) map[string]nomadVarItem {
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
	if strings.Contains(storefront, "_ALERT_TO_EMAIL") { t.Fatal("alert recipients must not enter the storefront") }
}
