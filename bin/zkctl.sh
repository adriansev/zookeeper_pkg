#!/usr/bin/env bash

export ZK_MAIN_ENV="${ZK_MAIN_ENV:-/etc/zookeeper/zk_main.env}"
[[ -f "${ZK_MAIN_ENV}" ]] && source "${ZK_MAIN_ENV}" || { echo "${ZK_MAIN_ENV} not found" ; exit 1; }
export ZK_LOG_DIR="${ZK_LOG_DIR:-$HOME}"

VERB=""${1,,}""
shift
[[ "${VERB}" == "dryrun" || "${VERB}" == "cmdline" ]] && { DRYRUN="1"; VERB=""${1,,}""; shift; }


help () {
echo "Commands:
dryrun | cmdline : just print the command line that would have been used
version | ver : Get the version of running ZooKeeper
cli : org.apache.zookeeper.ZooKeeperMain
snapshotcomparer : org.apache.zookeeper.server.SnapshotComparer
snapshotformatter : org.apache.zookeeper.server.SnapshotFormatter
tnxlog : org.apache.zookeeper.server.persistence.TxnLogToolkit
tnxlogpurge: org.apache.zookeeper.server.PurgeTxnLog
custom : run custom function found in the CLASSPATH jars
"
}

CMD="exec /usr/bin/java -Dzookeeper.log.dir=${HOME} ${JVMFLAGS} ${CLIENT_JVMFLAGS}"

DO_VER () { CMD_OPTS="org.apache.zookeeper.version.VersionInfoMain"; }

DO_CLI () {
    ZOO_LOG_FILE="zookeeper-${USER}-cli-${HOSTNAME}.log"
    CMD_OPTS="-Dzookeeper.log.file=${ZOO_LOG_FILE} org.apache.zookeeper.ZooKeeperMain"
}

DO_TNXLOG () {
    ZOO_LOG_FILE="zookeeper-${USER}-tnxlog-${HOSTNAME}.log"
    CMD_OPTS="-Dzookeeper.log.file=${ZOO_LOG_FILE} org.apache.zookeeper.server.persistence.TxnLogToolkit"
}

DO_TNXLOGPURGE () {
    ZOO_LOG_FILE="zookeeper-${USER}-cleanup-${HOSTNAME}.log"
    ZOOCFG=${ZOOCFG:-${ZK_CFGDIR}/zoo.cfg}

    ZOO_DATADIR="$(awk -F= '/^dataDir/{print $2}' ${ZOOCFG})"
    [[ -n ${ZOO_DATADIR} ]] && { echo "Could not get dataDir from ${ZOOCFG}"; exit 1; }

    ZOO_DATALOGDIR="$(awk -F= '/^dataLogDir/{print $2}' ${ZOOCFG})"

    if [[ -z "${ZOO_DATALOGDIR}" ]]; then
        CMD_OPTS=" org.apache.zookeeper.server.PurgeTxnLog ${ZOO_DATADIR}"
    else
        CMD_OPTS=" org.apache.zookeeper.server.PurgeTxnLog ${ZOO_DATALOGDIR} ${ZOO_DATADIR}"
    fi
}

DO_SNAPSHOTCOMPARE () {
    ZOO_LOG_FILE="zookeeper-${USER}-snapshotcomp-${HOSTNAME}.log"
    CMD_OPTS="org.apache.zookeeper.server.SnapshotComparer"
}

DO_SNAPSHOTFORMAT () {
    ZOO_LOG_FILE="zookeeper-${USER}-snapshotformat-${HOSTNAME}.log"
    CMD_OPTS="org.apache.zookeeper.server.SnapshotFormatter"
}

DO_CUSTOM () {
    ZOO_LOG_FILE="zookeeper-${USER}-custom-${HOSTNAME}.log"
    CUSTOM_FUNCTION="${1}"
    shift
    CMD_OPTS="${CUSTOM_FUNCTION}"
}

case "${VERB}" in
version|ver)
    DO_VER
    shift
    ;;
cli)
    DO_CLI
    shift
    ;;
tnxlog)
    DO_TNXLOG
    shift
    ;;
tnxlogpurge| cleanup)
    DO_TNXLOGPURGE
    shift
    ;;
snapshotcompare)
    DO_SNAPSHOTCOMPARE
    shift
    ;;
snapshotformat)
    DO_SNAPSHOTFORMAT
    shift
    ;;
custom)
    DO_CUSTOM
    shift
    ;;
-h|--h|-help|--help)
    shift
    help
    exit 0
    ;;
*) # unsupported flags, just catch any mistakes
    echo "Error: Unsupported verb: ${1}" >&2
    help
    exit 1
    ;;
esac

[[ -n "${DRYRUN}" ]] && CMD="echo ${CMD}"
${CMD} ${CMD_OPTS} "${@}"

