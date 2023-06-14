sudo virt-install --connect qemu:///system \
    --name testvm \
    --network=bridge:virbr1 --pxe \
    --ram=8192 \
    --vcpus=2 \
    --os-type=linux \
    --disk path=/var/lib/libvirt/images/testvm.qcow2,size=10