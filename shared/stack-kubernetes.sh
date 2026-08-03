#!/usr/bin/env bash
set -exo pipefail
# This script execute steps required to provision a working kubernetes stack. Idealy:
# - turn the VPN on
# - converge the stack
# This will make the stack available but will kill name resolution for what would usually be resolved with the vpn for internal ressources
# you can mute dns resolution with the `mute` verb.

RESOLV_CONF="$(realpath /etc/resolv.conf)"
status () { echo -e '\033[1;33m'"${@}"'\033[0m'; }
error () { echo -e '\033[1;31m'"${@}"'\033[0m'; exit 1; }

tf_provision (){
    [ -d "${1}" ] && [ -f ../${1}/versions.tf ]
    terraform -chdir="../${1}" init; terraform -chdir="../${1}" apply -auto-approve
    if [ -n "${2}" ]; then
        status "${2} seconds cooldown.."
        sleep ${2}
    fi
}

tf_removes (){
    [ -d "${1}" ] && [ -f ../${1}/versions.tf ]
    terraform -chdir="../${1}" init; terraform -chdir="../${1}" apply -auto-approve -destroy
    status "5 seconds cooldown.."
    sleep 5
}

# ideally, dns infos should have been set or injected through networkmanager, and having this tool to compile dns resolutions per interface
# however the VPN re-write the link to `/etc/resolv.conf`, bypassing networkmanager (and systemd-resolve).
dns_ferlab_lan () {
    !([ -f "../shared/resolv.conf" ]) && { error "stack hasn't been initialized"; }
    # commands here assume resolv.conf is only 1 line, and match a nameserver option. this is under-optimized and do not scale
    # in any form but resolves the issues at hand.
    case "$1" in
    add)
        grep -Fq "$(head -1 ../shared/resolv.conf | awk '{print $2}' | cut -f 1-3 -d'.')" "${RESOLV_CONF}" || sudo sed -i "1i $(head -1 ../shared/resolv.conf)"  "${RESOLV_CONF}"
        ;;
    delete)
        sudo sh -c "sed -i "/$(head -1 ../shared/resolv.conf | awk '{print $2}' | cut -f 1-3 -d'.')*/d" ${RESOLV_CONF}"
        sudo sh -c "sed -i "/ferlab*/d" ${RESOLV_CONF}"
        ;;
    cycle)
        dns_ferlab_lan delete # clean up
        dns_ferlab_lan add # re-inject
        ;;
    *)
        error "function error (dns_ferlab_lan)"
        ;;
    esac
}

# A few inter-linked dependencies in-between lower components may render libvirt untable to proceed with proper convergence if it diverges from
# states of each layers (and in sequence, especially for libvirt-network and etcd which cannot be recycled as they will break upper layers).
# It's therefore important to ensure each component state converge in sequence, and be destroyed in sequence with breaking failure if necessary (-eo pipefail)
case "$1" in
start)
    tf_provision default-pool
    tf_provision image
    tf_provision libvirt-network 10
    tf_provision etcd 30
    tf_provision netaddr 5
    tf_provision coredns
    status "wait for coredns availability.."
    while true; do dig +short google.com @$(tail -1 ../shared/resolv.conf | awk '{print $2}') &> /dev/null && break || sleep 10; done
    status "add coredns as name server in ${RESOLV_CONF}"
    dns_ferlab_lan add
    tf_provision nfs 30
    tf_provision kubernetes
    ;;
stop)
    tf_removes kubernetes
    tf_removes nfs
    dns_ferlab_lan delete
    tf_removes coredns
    tf_removes netaddr
    tf_removes etcd
    tf_removes libvirt-network
    ;;
dns) # mitigate issues with network changes
    dns_ferlab_lan cycle
    ;;
mute) # remove dns entries without cleaning the stack. stack will become unavailable but still running
    dns_ferlab_lan delete
;;
*)
    error "bad verb"
    ;;
esac
