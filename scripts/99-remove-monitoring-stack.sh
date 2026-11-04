#!/usr/bin/env bash
#
# OPTIONAL, DESTRUCTIVE, NOT PART OF THE MILESTONE 2 BUILD.
#
# Removes Grafana and InfluxDB to free ~288 MB of RAM for the YARN container
# pool. Requires root. Run it yourself -- it is kept out of the numbered build
# sequence on purpose.
#
# PERMANENTLY DESTROYS:
#   /var/lib/grafana    dashboards, users, the Grafana sqlite DB
#   /var/lib/influxdb   all time-series data collected since 2026-10-28
#   /etc/grafana        provisioning and grafana.ini
#   /etc/influxdb       influxdb config
#   ~/.influxdbv2       local influx CLI state (188 KB)
# There is no undo. Take a tar archive first if any of it matters.
#
# Usage:  sudo ./99-remove-monitoring-stack.sh
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo."; exit 1; }

echo "This will PERMANENTLY delete Grafana and InfluxDB data."
echo "Type exactly: DELETE"
read -r confirm
[ "${confirm}" = "DELETE" ] || { echo "Aborted."; exit 1; }

echo "==> stopping and disabling services"
systemctl disable --now grafana-server influxdb 2>/dev/null || true

echo "==> neutralising the influxdb2 postrm trap"
# influxdb2.postrm ends with an untolerated "systemctl disable influxdb".
# If the unit file is already gone the script exits non-zero and dpkg aborts
# the removal, leaving the package half-configured and blocking later apt
# runs. Its only real cleanup (rm -f /etc/default/influxdb) happens before
# that line, so forcing a zero exit loses nothing.
PR=/var/lib/dpkg/info/influxdb2.postrm
if [ -f "${PR}" ] && ! tail -1 "${PR}" | grep -q '^exit 0$'; then
  printf '\nexit 0\n' >> "${PR}"
fi

echo "==> purging packages"
# dpkg --purge, not apt purge: the installed Grafana version may no longer be
# in the configured repository, in which case apt cannot resolve it
# ("W: Can not find PkgVer for 'grafana'").
dpkg --purge influxdb2 grafana influxdb-client 2>/dev/null || true
apt-get autoremove -y || true

echo "==> removing data and config directories"
rm -rf /var/lib/grafana /var/lib/influxdb /etc/grafana /etc/influxdb
rm -rf "/home/${SUDO_USER:-$(logname 2>/dev/null)}/.influxdbv2"
rm -f  "/home/${SUDO_USER:-$(logname 2>/dev/null)}/.influx_history"

echo "==> result"
dpkg -l | grep -iE "grafana|influx" || echo "  no grafana/influx packages remain"
free -h
echo
echo "Done. Re-run scripts/04-stop-cluster.sh then 03-start-cluster.sh to pick up"
echo "any YARN memory changes."
