#!/usr/bin/env bash
set -exo pipefail

status () { echo -e '\033[1;33m'"${@}"'\033[0m'; }

tf_provision (){
    [ -d "${1}" ] && [ -f ../${1}/versions.tf ]
    terraform -chdir="../${1}" init; terraform -chdir="../${1}" apply -auto-approve
    if [ -n "${2}" ]; then
        status "cooldown for ${2} seconds .."
        sleep ${2}
    fi
}

tf_removes (){
    [ -d "${1}" ] && [ -f ../${1}/versions.tf ]
    terraform -chdir="../${1}" init; terraform -chdir="../${1}" apply -auto-approve -destroy
    sleep 5
}

case "$1" in
start)
    tf_provision default-pool
    tf_provision image
    tf_provision libvirt-network 10
    tf_provision etcd 30
    tf_provision netaddr 5
    tf_provision coredns
    status "add coredns as name server in /etc/resolv.conf"
    status "wait for coredns availability.."
    while true; do dig +short google.com @192.168.55.10 &> /dev/null && break || sleep 10; done
    grep -Fq '192.168.55' /etc/resolv.conf || sudo sed -i "1i $(cat ../shared/resolv.conf)"  /etc/resolv.conf
    tf_provision nfs 30
    tf_provision kubernetes
    ;;
stop)
    tf_removes kubernetes
    tf_removes nfs
    grep -Fq '192.168.55' /etc/resolv.conf && sudo sh -c "sed -i '/192.168.55*/d' /etc/resolv.conf"
    tf_removes coredns
    tf_removes netaddr
    tf_removes etcd
    tf_removes libvirt-network
    ;;
*)
    echo "bad verb"
    ;;
esac
