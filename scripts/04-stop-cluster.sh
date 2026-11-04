#!/usr/bin/env bash
# Stop YARN + HDFS. Leaves all data on disk.
set -uo pipefail
. "$(dirname "$0")/00-env.sh"

log "Stopping YARN"
"${HADOOP_HOME}/sbin/stop-yarn.sh" || true
log "Stopping HDFS"
"${HADOOP_HOME}/sbin/stop-dfs.sh" || true
log "Remaining Java processes"
"${JAVA_HOME}/bin/jps"
