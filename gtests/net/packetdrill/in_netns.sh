#!/bin/bash
#
# Execute a subprocess in a network namespace

set -e

readonly NETNS="ns-$(mktemp -u XXXXXX)"

# last arg is the file name
for i in "${@}"; do pkt="${i}"; done
for i in "${@}"; do [[ "${i}" = "--ip_version="* ]] && ipv="${i#*=}"; done
OUTPUT="${HOME}/${pkt}_${ipv}.pcap"
PID=

setup() {
	ip netns add "${NETNS}"
	ip -netns "${NETNS}" link set lo up
	ip netns exec "${NETNS}" tcpdump -i any -s 150 -w "${OUTPUT}" &
	PID=$!
	sleep 1
}

cleanup() {
	kill ${PID}
	ip netns del "${NETNS}"
}

trap cleanup EXIT
setup

ip netns exec "${NETNS}" "$@"
exit "$?"
