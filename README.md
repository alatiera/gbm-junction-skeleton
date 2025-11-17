# Template repo for gnome-build-meta junctions

It comes with an OCI layer and a bootc setup. See the [Justfile](./Justfile)

Everything that needs replacing is named `placeholder`

```
just && just build-containerfile && BUILD_BASE_DIR=/tmp just generate-bootable-image && just run-qemu-vm
```
