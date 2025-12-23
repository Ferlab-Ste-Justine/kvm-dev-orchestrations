#!/bin/bash

kill_host_metrics() {
    echo "Terminating host metric processes..."
    pkill -P $$ 
    echo "Host metric processes terminated."
}

trap 'kill_host_metrics; exit' EXIT SIGINT SIGTERM

echo "Starting host metric processes..."

{ node_exporter; } &

{ prometheus-libvirt-exporter; } &

wait