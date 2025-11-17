default: build

# oci/placeholder.bst
image_name := env("BUILD_IMAGE_NAME", "placeholder")
image_tag := env("BUILD_IMAGE_TAG", "latest")
base_dir := env("BUILD_BASE_DIR", ".")
filesystem := env("BUILD_FILESYSTEM", "btrfs")

build *ARGS:
    #!/usr/bin/env bash
    set -eu

    bst --strict build oci/placeholder.bst
    bst artifact checkout --tar - oci/placeholder.bst | run0 podman load

# Ideally we wouldn't need the Containerfile nor the podman build
# and be able to use the image as-is
# but we run into issues when it has a remote uri
# https://github.com/bootc-dev/bootc/issues/1703
build-containerfile $image_name=image_name:
    run0 podman build --squash-all -t "${image_name}:latest" .

bootc *ARGS:
    run0 podman run \
        --rm --privileged --pid=host \
        -it \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        -v "{{base_dir}}:/data" \
        --security-opt label=type:unconfined_t \
        "{{image_name}}:{{image_tag}}" bootc {{ARGS}}

generate-bootable-image $base_dir=base_dir $filesystem=filesystem:
    #!/usr/bin/env bash
    if [ ! -e "${base_dir}/bootable.img" ] ; then
        fallocate -l 25G "${base_dir}/bootable.img"
    fi

    just bootc install to-disk --composefs-backend \
        --via-loopback /data/bootable.img \
        --filesystem "${filesystem}" \
        --wipe \
        --bootloader systemd \
        --karg systemd.firstboot=no \
        --karg splash \
        --karg quiet \
        --karg console=tty0 \
        --karg systemd.debug_shell=ttyS1

# Run the VM with QEMU using OVMF for UEFI support
run-qemu-vm:
    #!/usr/bin/env bash
    cp "/usr/share/ovmf/OVMF_CODE.fd" "./OVMF_CODE.fd"
    cp "/usr/share/ovmf/OVMF_VARS.fd" "./OVMF_VARS.fd"

    # smbios only works with UKIs with sdboot
    cmdline=()
    # cmdline+=("systemd.firstboot=no")
    cmdline+=("console=ttyS0")
    cmdline+=("systemd.debug_shell=ttyS1")
    cmdline+=("gnome.initial-setup=0")
    cmdline+=("systemd.unit=multi-user.target")
    TYPE11=("value=io.systemd.stub.kernel-cmdline-extra=${cmdline[*]//,/,,}")

    # QEMU_ARGS+=()
    if [ ${#TYPE11[@]} -gt 0 ]; then
        TYPE11ALL="$(IFS=,; echo "${TYPE11[*]}")"
        echo "$TYPE11ALL"
        # QEMU_ARGS+=(-smbios "type=11,${TYPE11ALL}")
    fi

        # -drive "if=none,id=boot-disk,file=/home/alatiera/Downloads/gnome_os_943321-x86_64.iso,media=disk,format=raw,discard=on" \
    qemu-system-x86_64 \
        -m 8G \
        -M q35,accel=kvm \
        -cpu host \
        -smp 4 \
        -netdev user,id=net1 \
        -device virtio-net-pci,netdev=net1,bootindex=-1,romfile= \
        -drive if=pflash,format=raw,readonly=on,file="./OVMF_CODE.fd" \
        -drive if=pflash,format=raw,file="./OVMF_VARS.fd" \
        -drive "if=none,id=boot-disk,file=/tmp/bootable.img,media=disk,format=raw,discard=on" \
        -device "virtio-blk-pci,drive=boot-disk,bootindex=1" \
        -device virtio-vga-gl \
        -display gtk,gl=on \
        -device ich9-intel-hda \
        -audiodev pa,id=sound0 \
        -device hda-output,audiodev=sound0 \
        -device vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=777 \
        -chardev pty,id=term0 \
        -serial chardev:term0 \
        -chardev pty,id=term1 \
        -serial chardev:term1 \
        -usbdevice tablet \
        -smbios "type=11,value=io.systemd.stub.kernel-cmdline-extra=console=ttyS0 systemd.debug_shell=ttyS1 systemd.zram=0 gnome.initial-setup=0 systemd.firstboot=no"

        # -smbios "type=11,value=io.systemd.stub.kernel-cmdline-extra=gnome.initial-setup=0 systemd.firstboot=no systemd.zram=0 console=ttyS0 systemd.debug_shell=ttyS1 systemd.unit=multi-user.target"
        # -smbios type=11,value=io.systemd.stub.kernel-cmdline-extra=console=ttyS0
