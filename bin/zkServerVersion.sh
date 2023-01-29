#!/usr/bin/env bash

[[ -f /etc/sysconfig/zookeeper.env ]] && source /etc/sysconfig/zookeeper.env || { echo "/etc/sysconfig/zookeeper.env not found" ; exit 1; }
exec ${JAVA} -cp "${CLASSPATH}" org.apache.zookeeper.version.VersionInfoMain

