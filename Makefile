.PHONY: vm clean pristine

# To step through the build process, add the `-debug` option to the `packer build` command.
# To see additional logging, run `packer build` with the `PACKER_LOG=1` env var.

images/ubuntu-server: ssh/user-key
	packer init qemu.pkr.hcl
	packer validate qemu.pkr.hcl
	packer fmt qemu.pkr.hcl
	packer build -on-error=ask qemu.pkr.hcl

ssh/%-key:
	ssh-keygen -t ed25519 -N '' -f $@

vm: images/ubuntu-server
	qemu-system-x86_64 \
		-name ubuntu-server \
		-nodefaults -no-user-config \
		-machine type=q35,accel=kvm \
		-cpu host -smp 2 -m 2048M \
		-device virtio-net-pci,netdev=user.0 \
		-netdev user,id=user.0,hostfwd=tcp::2222-:22 \
		-drive file=images/ubuntu-server,if=virtio,media=disk,format=qcow2 \
		-vga virtio -serial stdio

clean:
	rm -rf images

pristine:
	git clean -dxf --exclude .idea/
