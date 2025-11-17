kind: stack

depends:
  # FIXME: this is a copy paste to avoid signed things mostly
  # - gnome-build-meta.bst:oci/gnomeos/stack.bst
  - gnome-build-meta.bst:oci/integration/os-release.bst
  - placeholder/deps.bst

  # Add the kernel
  # - freedesktop-sdk.bst:components/linux.bst
  - freedesktop-sdk.bst:components/linux-firmware.bst
  - gnome-build-meta.bst:gnomeos/initramfs/signed-modules.bst
  - gnome-build-meta.bst:oci/initramfs.bst

  # Currently only in -devel
  - gnome-build-meta.bst:gnomeos-deps/bootc.bst
  - gnome-build-meta.bst:oci/integration/bootc-config.bst
  - freedesktop-sdk.bst:vm/config/useradd-ostree.bst
  - freedesktop-sdk.bst:vm/config/sudo-nopasswd.bst

public:
  bst:
    integration-commands:
    # # Required for bootc to create the image
    - mkdir /boot
    - mkdir /sysroot
    - mkdir /sysroot/ostree
    # This needs to be a relative symlink
    # for some reason
    - ln -s sysroot/ostree ostree

    - rm --verbose --recursive --force /root
    # These also get created by 10-bootc.conf tmpfiles
    # but we need them to exist for the OCI image to
    # be usable as a container as well
    - mkdir /var/home
    - mkdir /var/roothome
    - mkdir /var/opt
    - mkdir /var/mnt

    - ln -s /var/home /home
    - ln -s /var/roothome /root
    - ln -s /var/opt /opt
    - ln -s /var/mnt /mnt

    - touch /etc/machine-id

      # Wipe /var (may contain build-time state) and all FHS dirs that should
      # be symlinks into /var, then recreate with the correct structure.
      # Relative symlinks (var/home not /var/home) match zirconium-hawaii and
      # are safer in chroot/deploy tooling flows.
      # - rm -rfv /home /root /opt /mnt /srv /var
      # - mkdir -p /var/home /var/roothome /var/opt /var/mnt /var/srv /var/tmp
      # - ln -s var/home /home
      # - ln -s var/roothome /root
      # - ln -s var/opt /opt
      # - ln -s var/mnt /mnt
      # - ln -s var/srv /srv
