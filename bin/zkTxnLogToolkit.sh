#!/usr/bin/env bash

[[ -f /etc/sysconfig/zookeeper.env ]] && source /etc/sysconfig/zookeeper.env || { echo "/etc/sysconfig/zookeeper.env not found" ; exit 1; }
ZOO_LOG_FILE="zookeeper-${USER}-cleanup-${HOSTNAME}.log"

exec "$JAVA" -cp "${CLASSPATH}" ${JVMFLAGS} org.apache.zookeeper.server.persistence.TxnLogToolkit "$@"

