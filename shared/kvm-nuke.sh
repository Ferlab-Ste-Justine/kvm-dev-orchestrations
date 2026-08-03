#!/bin/sh
set -eo pipefail

# ===================== IMPORTANT =====================
# BEFORE RUNNING THIS SCRIPT, READ ITS CONTENTS CAREFULLY.
# Scripts with broad deletion mechanisms are INHERENTLY DANGEROUS.
# Always BACK UP any important data before proceeding.
# Do NOT run unless you fully understand the consequences.
# =====================================================

cat <<EOF
# ===================== DANGER! =====================
# This script will IRREVERSIBLY DELETE ALL libvirt resources.
# ALL VMs, storage, pools, and networks WILL BE LOST FOREVER.
# THERE IS NO UNDO. THIS IS YOUR FINAL WARNING.
# ===================== DANGER! =====================

Are you ABSOLUTELY SURE you want to continue? (type YES to proceed):
EOF
read confirm
if [ "$confirm" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# Ensure script is executed from its own directory
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"; cd "$SCRIPT_DIR"

# Delete all virtual machines (domains)
echo "Listing all virtual machines (domains) to be deleted:"
sudo virsh list --all --name | while read vm; do
    if [ -n "$vm" ]; then
        echo "Shutting down and deleting VM: $vm"
        sudo virsh destroy "$vm" 2>/dev/null # Shut down if running
        sudo virsh undefine "$vm" --remove-all-storage
        echo "Deleted VM: $vm (including associated storage if possible)"
    fi
done

# echo "All VMs deleted."

# Delete all storage volumes in all pools
echo "Listing all storage pools:"
sudo virsh pool-list --all --name | while read pool; do
    if [ -n "$pool" ]; then
        echo "Processing storage pool: $pool"
        sudo virsh vol-list "$pool" | awk 'NR>2 && $1 != "" {print $1}' | while read vol; do
            if [ -n "$vol" ]; then
                echo "Deleting storage volume: $vol in pool: $pool"
                sudo virsh vol-delete "$vol" --pool "$pool"
            fi
        done
    fi
done

echo "Deleting all storage pools:"
sudo virsh pool-list --all --name | while read pool; do
    if [ -n "$pool" ]; then
        echo "Deleting storage pool: $pool"
        sudo virsh pool-destroy "$pool" 2>/dev/null
        sudo virsh pool-undefine "$pool"
    fi
done

echo "All storage volumes and pools deleted."
# Delete all networks
echo "Listing all networks:"
sudo virsh net-list --all --name | while read net; do
    if [ -n "$net" ]; then
        echo "Destroying and undefining network: $net"
        sudo virsh net-destroy "$net" 2>/dev/null
        sudo virsh net-undefine "$net"
    fi
done

echo "Libvirt environment nuked. All VMs, storage volumes, pools, and networks have been deleted."

# Prompt user for confirmation before deleting unmanaged pool data and Terraform contexts
echo "WARNING: This next step will IRREVERSIBLY DELETE any remaining libvirt unmanaged pool data and all Terraform contexts (downloaded modules, state files, etc)."
echo "Are you ABSOLUTELY SURE you want to continue? (type YES to proceed):"
read confirm
echo
if [ "$confirm" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# Ask user if they want to delete the folder specified in ./default_pool_path
pool_path=""
if [ -f ./default_pool_path ]; then
    pool_path="$(cat ./default_pool_path | tr -d '\n')"
    # Check if pool_path is not empty and is an absolute path
    if [ -n "$pool_path" ] && [ "${pool_path#/}" != "$pool_path" ]; then
        echo "Do you want to IRREVERSIBLY DELETE the folder: $pool_path ? (type YES to confirm):"
        read confirm
        echo
        if [ "$confirm" != "YES" ]; then
            echo "Aborted."
            pool_path=""
        fi
    else
        echo "Warning: ./default_pool_path does not contain a valid absolute path. Skipping deletion."
        pool_path=""
    fi
else
    echo "No ./default_pool_path file found. Skipping pool folder deletion."
fi

if [ -n "$pool_path" ]; then
    echo "Deleting $pool_path ..."
    sudo rm -rf -- "$pool_path"
    echo "Deleted: $pool_path"
fi

find ../ -type d -name '.terraform' -prune
find ../ -name 'terraform.tfstate' -not -path '*/.terraform/*' -type f

echo "Ready to delete above listed .terraform folders and terraform.tfstate files. Continue? (type YES to confirm):"
read confirm
if [ "$confirm" == "YES" ]; then
    find ../ -type d -name '.terraform' -prune -exec rm -rf {} + 2>/dev/null || true
    find ../ -name 'terraform.tfstate' -type f -delete
fi

# Why not use Terraform destroy?
# --------------------------------------------------
# Use Terraform destroy if possible; use this script only if that fails.
