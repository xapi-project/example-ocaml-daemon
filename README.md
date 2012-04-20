# example-ocaml-daemon

A minimal daemon that can be used as a starting point when implementing a
daemon to run alongside [xen-api](https://github.com/xen-org/xen-api).

Even this minimal daemon has a few dependencies, e.g. `http-svr`, `stunnel`,
`xml-light2`, `rpc-light`, and `camlp4`. If the repository is cloned within
the `ocaml` directory of [xen-api](https://github.com/xen-org/xen-api), all
the dependencies should be satisfied.

## Compiling

* The daemon server can be compiled by running `omake daemon_server`.
* The daemon client can be compiled by running `omake daemon_client`.
* The test can be run by running `omake test`.

You might need to define a global variable `OPTDIR`, e.g.:

    export OPTDIR=""
