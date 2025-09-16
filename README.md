Ubuntu Server QEMU Image
========================

This project contains the necessary files to build a Ubuntu Server qcow2 image for use with QEMU.


Prerequisites
-------------

* Packer: You must have HashiCorp Packer installed.

* QEMU: You need QEMU installed.

* KVM: It is highly recommended to have KVM enabled for hardware acceleration.  Add your user to
  the `kvm` group.


How to Build the Image
----------------------

```shell
make images/ubuntu-server
```


How to Run the Generated Image
------------------------------

Once the build is complete, you can run your new VM with

```shell
make vm
```


Logging Into The VM
-------------------

You can SSH into the running VM with:

```shell
ssh -F ssh/user-config ubuntu-server
```
