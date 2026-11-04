#!/usr/bin/env bash
# Common environment for every script in this directory. Source, do not execute.
set -o pipefail

export REPO_DIR="/home/jiho/tpcxhs-m2"
export OPT_DIR="/home/jiho/opt"
export DATA_DIR="/home/jiho/hadoop-data"

export JAVA_HOME="${OPT_DIR}/java8"
export HADOOP_HOME="${OPT_DIR}/hadoop"
export HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
export HADOOP_MAPRED_HOME="${HADOOP_HOME}"
export HADOOP_COMMON_HOME="${HADOOP_HOME}"
export HADOOP_HDFS_HOME="${HADOOP_HOME}"
export YARN_HOME="${HADOOP_HOME}"
export HADOOP_COMMON_LIB_NATIVE_DIR="${HADOOP_HOME}/lib/native"
export LD_LIBRARY_PATH="${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH:-}"
export PATH="${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

# Versions pinned for Milestone 2 (aarch64 / Ubuntu 22.04)
export HADOOP_VERSION="3.3.6"
export HADOOP_TARBALL="hadoop-${HADOOP_VERSION}-aarch64.tar.gz"
export HADOOP_URL="https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_TARBALL}"
export JDK_TARBALL="temurin8-aarch64.tar.gz"
export JDK_URL="https://api.adoptium.net/v3/binary/latest/8/ga/linux/aarch64/jdk/hotspot/normal/eclipse"

log()  { printf '\n[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
die()  { printf '\nERROR: %s\n' "$*" >&2; exit 1; }
