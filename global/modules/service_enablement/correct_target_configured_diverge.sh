
set -euo pipefail

sed -i 's|http://[0-9.]*:3100|http://192.168.1.99:3100|' /etc/promtail/config.yaml
systemctl restart promtail
