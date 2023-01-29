#!/usr/bin/env bash

[[ -f /etc/sysconfig/zookeeper.env ]] && source /etc/sysconfig/zookeeper.env || { echo "/etc/sysconfig/zookeeper.env not found" ; exit 1; }
ZOO_LOG_FILE="${HOME}/zookeeper-${USER}-initialize-${HOSTNAME}.log"
ZOOCFG="${ZOOCFGDIR}/zoo.cfg"

usage() {
  # the configfile will be properly formatted as long as the
  # configfile path is less then 40 chars, otw the line will look a
  # bit weird, but otherwise it's fine
  printf "usage: $0 <parameters>
  Optional parameters:
     -h                                                    Display this message
     --help                                                Display this message
     --configfile=%-40s ZooKeeper config file
     --myid=#                                              Set the myid to be used, if any (1-255)
     --force                                               Force creation of the data/txnlog dirs
" "${ZOOCFG}"
  exit 1
}

[[ $? != 0 ]] && { usage; exit 1; }

initialize() {
    [[ -e "${ZOOCFG}" ]] || { echo "Unable to find config file at ${ZOOCFG}"; exit 1; }

    ZOO_DATADIR="$(awk -F= '/^dataDir/{print $2}' ${ZOOCFG})"
    ZOO_DATALOGDIR="$(awk -F= '/^dataLogDir/{print $2}' ${ZOOCFG})"

    [[ -z "${ZOO_DATADIR}" ]] && { echo "Unable to determine dataDir from ${ZOOCFG}"; exit 1; }

    if [ $FORCE ]; then
        echo "Force enabled, data/txnlog directories will be re-initialized"
    else
        # we create if version-2 exists (ie real data), not the parent. See comments in following section for more insight
        [[ -d "${ZOO_DATADIR}/version-2" ]] && { echo "ZooKeeper data directory already exists at ${ZOO_DATADIR} (or use --force to force re-initialization)"; exit 1; }
        [[ -n "${ZOO_DATALOGDIR}" && -d "${ZOO_DATALOGDIR}/version-2" ]] && { echo "ZooKeeper txnlog directory already exists at ${ZOO_DATALOGDIR} (or use --force to force re-initialization)"; exit 1; }
    fi

    rm -rf "${ZOO_DATADIR}/myid" "${ZOO_DATADIR}/version-2"  &>/dev/null
    mkdir -p "${ZOO_DATADIR}/version-2"

    if [ -n "${ZOO_DATALOGDIR}" ]; then
        rm -rf "${ZOO_DATALOGDIR}/myid" "${ZOO_DATALOGDIR}/version-2" &>/dev/null
        mkdir -p "${ZOO_DATALOGDIR}/version-2"
    fi

    if [ ${MYID} ]; then
        echo "Using myid: ${MYID}"
        echo ${MYID} > "${ZOO_DATADIR}/myid"
    else
        echo "No myid provided, be sure to specify it in $ZOO_DATADIR/myid if using non-standalone"
    fi

    touch "${ZOO_DATADIR}/initialize"
    chown -R zookeeper:zookeeper ${ZOO_DATADIR}
}

while [ ! -z "$1" ]; do
  case "$1" in
    --configfile)
      ZOOCFG=$2; shift 2
      ;;
    --configfile=?*)
      ZOOCFG=${1#*=}; shift 1
      ;;
    --myid)
      MYID=$2; shift 2
      ;;
    --myid=?*)
      MYID=${1#*=}; shift 1
      ;;
    --force)
      FORCE=1; shift 1
      ;;
    -h)
      usage
      ;; 
    --help)
      usage
      ;; 
    *)
      echo "Unknown option: $1"
      usage
      exit 1 
      ;;
  esac
done
initialize

