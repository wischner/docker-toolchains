# OpenLook Source Packages

This directory contains source archives used by the OpenLook image build:

- `xview-base.tar.gz`
- `xview-lib-extras.tar.gz`

The Dockerfile prefers these local files for reproducible builds.  
If a file is missing, it falls back to downloading from the configured URL.
