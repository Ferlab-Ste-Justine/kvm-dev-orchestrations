apt-get update;
apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system xsltproc mkisofs;
systemctl enable libvirtd;

if [ -f "shared/default_pool_path" ]; then
  POOL_PATH=$(cat shared/default_pool_path)
  if [ "${POOL_PATH#/home/}" != "$POOL_PATH" ] ; then
    echo "Save yourself some pain and don't place the default volume pool path under a home directory";
    exit 1;
  fi

  mkdir -p $(cat shared/default_pool_path);
  TEMPLATE=$(cat <<-EndOfMessage
#
# This profile is for the domain whose UUID matches this file.
#

#include <tunables/global>

profile LIBVIRT_TEMPLATE flags=(attach_disconnected) {
  #include <abstractions/libvirt-qemu>
  $POOL_PATH/ r,
  $POOL_PATH/** rwk, 
}
EndOfMessage
)
  echo "$TEMPLATE" > /etc/apparmor.d/libvirt/TEMPLATE.qemu
fi
