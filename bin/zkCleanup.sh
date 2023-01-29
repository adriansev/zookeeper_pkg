#!/usr/bin/env bash

[[ -f /etc/sysconfig/zookeeper.env ]] && source /etc/sysconfig/zookeeper.env || { echo "/etc/sysconfig/zookeeper.env not found" ; exit 1; }

ZOODATADIR="$(grep "^[[:space:]]*dataDir=" "$ZOOCFG" | sed -e 's/.*=//')"
ZOODATALOGDIR="$(grep "^[[:space:]]*dataLogDir=" "$ZOOCFG" | sed -e 's/.*=//')"

ZOO_LOG_FILE="zookeeper-${USER}-cleanup-${HOSTNAME}.log"

MAIN_CMD="exec ${JAVA} -Dzookeeper.log.dir=${ZOO_LOG_DIR} -Dzookeeper.log.file=${ZOO_LOG_FILE} -cp ${CLASSPATH} ${JVMFLAGS} org.apache.zookeeper.server.PurgeTxnLog"

if [[ -z "${ZOODATALOGDIR}" ]]; then
    ${MAIN_CMD} "${ZOODATADIR}" $*
else
    ${MAIN_CMD} "${ZOODATALOGDIR}" "${ZOODATADIR}" $*
fi

