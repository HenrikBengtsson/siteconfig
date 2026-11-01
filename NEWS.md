# Version 0.0.1 [2026-10-31]

## New Features

 * Added `bioc_version()` for inferring the default Bioconductor version
   from environment variable `R_BIOC_VERSION`, installed 'BiocVersion',
   'BiocManager', or the R version.

 * Added `no_internet()`, which respects environment variable `NO_INTERNET`.

 * Added `use()`, which calls `use_repos()` and then unloads the package
   unless it is attached.

 * Added `local_mirror_root()`, `default_repos()`, and `use_repos()` for
   setting up CRAN and Bioconductor repositories, using local file-system
   mirrors when there is no internet access.
