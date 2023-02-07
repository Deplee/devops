#!/bin/bash


case "$1" in
    "c"|"create")
        echo "[Done]. QEMU ISO will be created soon..."
        exec qemu-img create -f qcow2 work.qcow 60G ;;
    "i"|"install")
        echo "[Done]. QEMU will be run for install soon..."
        exec qemu-system-x86_64 -enable-kvm  \
            -hda work.qcow -boot d -cdrom ubuntu-22.04.1-desktop-amd64.iso \
            -m 4G -cpu host -smp 4 \
            --device virtio-vga, xres=1680,yres=1050 \
            --full-screen ;;
    "r"|"run")
        echo "[Done]. QEMU will be run soon..."
        exec qemu-system-x86_64 -cpu host \
            --enable-kvm \
            -m 4G -smp 4 \
            -hda work.qcow \
            -device virtio-vga,xres=1920,yres=1080 \
            --full-screen ;;
    *)
        echo "[Error]. Available options: c|create, i|install, r|run ."
        exit 1 ;;
esac
