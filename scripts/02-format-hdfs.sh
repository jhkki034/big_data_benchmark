#!/usr/bin/env bash
# Format the NameNode. REFUSES to run if a filesystem image already exists,
# so an accidental re-run can never silently discard HDFS data.
set -euo pipefail
. "$(dirname "$0")/00-env.sh"

if [ -d "${DATA_DIR}/nn/current" ]; then
  echo "A NameNode image already exists at ${DATA_DIR}/nn/current."
  echo "Formatting would DESTROY all HDFS data."
  echo
  echo "If that is really what you want, remove the directory by hand first:"
  echo "    rm -rf ${DATA_DIR}/nn ${DATA_DIR}/dn"
  echo "then re-run this script. Refusing to proceed."
  exit 1
fi

mkdir -p "${DATA_DIR}"/{nn,dn,tmp,logs,pids,yarn/local,yarn/logs}
log "Formatting NameNode (cluster id fixed for reproducibility)"
"${HADOOP_HOME}/bin/hdfs" namenode -format -clusterId tpcxhs-m2 -nonInteractive
log "Format done"
