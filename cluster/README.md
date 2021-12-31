The Git repository contains the following directories under cluster and are ordered below by how Flux will apply them.

base directory is the entrypoint to Flux
crds directory contains custom resource definitions (CRDs) that need to exist globally in your cluster before anything else exists
core directory (depends on crds) are important infrastructure applications (grouped by namespace) that should never be pruned by Flux
apps directory (depends on core) is where your common applications (grouped by namespace) could be placed, Flux will prune resources here if they are not tracked by Git anymore

./cluster
├── ./apps
├── ./base
├── ./core
└── ./crds
