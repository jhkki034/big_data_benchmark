#!/usr/bin/env bash
# Verify the cluster and any generated dataset. Read-only: changes nothing.
set -uo pipefail
. "$(dirname "$0")/00-env.sh"

OUT="${1:-}"

log "Daemons (jps)"
"${JAVA_HOME}/bin/jps"

log "HDFS health"
"${HADOOP_HOME}/bin/hdfs" dfsadmin -report | sed -n '1,18p'

log "HDFS fsck /"
"${HADOOP_HOME}/bin/hdfs" fsck / | tail -25

log "YARN nodes"
"${HADOOP_HOME}/bin/yarn" node -list 2>/dev/null | tail -5

if [ -n "${OUT}" ]; then
  log "Dataset ${OUT}"
  "${HADOOP_HOME}/bin/hdfs" dfs -ls "${OUT}"
  echo
  "${HADOOP_HOME}/bin/hdfs" dfs -du -h "${OUT}"
  echo
  "${HADOOP_HOME}/bin/hdfs" dfs -du -h -s "${OUT}"
  log "First record (100 bytes, 10-byte key + 90-byte value)"
  "${HADOOP_HOME}/bin/hdfs" dfs -cat "${OUT}/part-m-00000" 2>/dev/null | head -c 100 | od -c | head -8
fi

log "Local disk"
df -h /
