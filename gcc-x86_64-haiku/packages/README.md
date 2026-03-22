# Optional Local Haiku Packages

You usually do **not** need to put anything in this folder.

The `gcc-x86_64-haiku` Docker build now automatically downloads the required
runtime packages from the EU mirror:

- `haiku-<version>-1-x86_64.hpkg`
- `haiku_devel-<version>-1-x86_64.hpkg`

`<version>` is resolved from the latest nightly by default (`HAIKU_PACKAGE_VERSION=latest`).

## When to use this folder

Use this folder only if you want to override automatic download, for example:

- building offline
- pinning to a custom package pair
- testing local/cached package files

## Local override format

If both files are present, the Docker build uses them instead of downloading:

1. `haiku-*.hpkg`
2. `haiku_devel-*.hpkg`

Examples:

- `haiku-r1~beta5_hrev59523-1-x86_64.hpkg`
- `haiku_devel-r1~beta5_hrev59523-1-x86_64.hpkg`

## .gitignore

`.hpkg` files are excluded from git (see `.gitignore`) because they are large binaries.
