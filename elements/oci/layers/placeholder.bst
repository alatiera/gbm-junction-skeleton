kind: compose

build-depends:
- oci/layers/placeholder-stack.bst

config:
  exclude:
  - debug
  - devel
  - doc
  - extra
  - static-blocklist
