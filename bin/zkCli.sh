#!/usr/bin/env bash

[[ -f /etc/sysconfig/zookeeper.env ]] && source /etc/sysconfig/zookeeper.env || { echo "/etc/sysconfig/zookeeper.env not found" ; exit 1; }
ZOO_LOG_FILE="zookeeper-${USER}-cleanup-${HOSTNAME}.log"

exec "$JAVA" "-Dzookeeper.log.dir=${ZOO_LOG_DIR}" "-Dzookeeper.log.file=${ZOO_LOG_FILE}" -cp "${CLASSPATH}" ${CLIENT_JVMFLAGS} ${JVMFLAGS} org.apache.zookeeper.ZooKeeperMain "$@"

