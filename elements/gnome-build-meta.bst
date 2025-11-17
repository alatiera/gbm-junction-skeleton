kind: junction

sources:
- kind: git_repo
  url: gnome:gnome-build-meta.git
  # Custom branch with bootc and generate-keys support
  # keys: https://gitlab.gnome.org/GNOME/gnome-build-meta/-/merge_requests/4289
  track: master
  ref: 49-branchpoint-648-ga6cdea67b6351043edc55b6797c5302e58528f51

config:
  options:
    arch: '%{arch}'
    (?):
    - x86_64_v3:
        x86_64_v3: true

  overrides:
    # This along with the patches is required and has to match
    # what gnome-build-meta is using
    freedesktop-sdk.bst: freedesktop-sdk.bst

    # Replace the element so the OCI image doesn't have any apps
    # FIXME: override os-release as well
    # FIXME: Add manifest.json
    core/meta-gnome-core-apps.bst: core/meta-gnome-core-apps.bst

    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst

    # Override the keys we use to sign things with our own element
    # gnomeos/linux-module-cert.bst: core/linux-module-cert.bst
    gnomeos/initramfs/signed-modules.bst: core/unsigned-modules.bst
