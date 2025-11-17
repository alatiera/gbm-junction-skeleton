kind: junction

sources:
- kind: git_repo
  url: gnome:gnome-build-meta.git
  # Custom branch with bootc and generate-keys support
  # keys: https://gitlab.gnome.org/GNOME/gnome-build-meta/-/merge_requests/4289
  track: master
  ref: 49-branchpoint-795-g0561079c59243776fa57412669eaaef4e6eee195
- kind: patch_queue
  path: patches/gnome-build-meta

config:
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
