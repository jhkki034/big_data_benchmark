#!/usr/bin/env bash
# Start HDFS + YARN and wait until the cluster reports healthy.
set -euo pipefail
. "$(dirname "$0")/00-env.sh"

[ -d "${DATA_DIR}/nn/current" ] || die "NameNode not formatted. Run 02-format-hdfs.sh first."

log "Starting HDFS"
"${HADOOP_HOME}/sbin/start-dfs.sh"
log "Starting YARN"
"${HADOOP_HOME}/sbin/start-yarn.sh"

log "Waiting for HDFS to leave safe mode"
"${HADOOP_HOME}/bin/hdfs" dfsadmin -safemode wait

log "jps"
"${JAVA_HOME}/bin/jps"

log "Daemon check"
rc=0
for d in NameNode DataNode ResourceManager NodeManager SecondaryNameNode; do
  if "${JAVA_HOME}/bin/jps" | grep -qw "${d}"; then
    echo "  OK      ${d}"
  else
    echo "  MISSING ${d}"; rc=1
  fi
done

log "HDFS report"
"${HADOOP_HOME}/bin/hdfs" dfsadmin -report | head -20

[ "${rc}" -eq 0 ] && log "Cluster up" || die "One or more daemons failed; see ${DATA_DIR}/logs"
