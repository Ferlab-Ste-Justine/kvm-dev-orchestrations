sudo virt-install --connect qemu:///system \
    --name testvm \
    --network network=ferlab --pxe \
    --ram=8192 \
    --vcpus=2 \
    --os-type=linux \
    --disk path=/var/lib/libvirt/images/testvm.qcow2,size=10