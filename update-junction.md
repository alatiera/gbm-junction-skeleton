# How to update the junction

```sh
bst source track gnome-build-meta.bst freedesktop-sdk.bst
# Sync the plugins
cp ../gnome-build-meta/elements/plugins/ elements/ -r
# Sync the fdo-sdk patches
# Also need to cleanup any patches that are no longer needed
# rm -r patches/{freedesktop-sdk, gnome-build-meta}
cp ../gnome-build-meta/patches/freedesktop-sdk/ patches/ -r
# Rebase any needed patches for gnome-build-meta
mkdir -p patches/gnome-build-meta
cd patches/gnome-build-meta
wcurl https://gitlab.gnome.org/GNOME/gnome-build-meta/-/merge_requests/4289.patch
```
