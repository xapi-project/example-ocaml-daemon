# example-ocaml-daemon

A minimal daemon that can be used as a starting point when implementing a
daemon to run alongside [xen-api](https://github.com/xen-org/xen-api).

Even this minimal daemon has a few dependencies, e.g. `http-svr`, `stunnel`,
`xml-light2`, `rpc-light`, and `camlp4`. If the repository is cloned within
the `ocaml` directory of [xen-api](https://github.com/xen-org/xen-api), all
of these dependencies should be satisfied.

## Setting up with xen-api

* Clone the repository within `xen-api/ocaml`.
* Rename the repository's directory to `<my_daemon>`.
* Remove `.git`, `.gitignore`, and `README.md` within the `<my_daemon>`
  directory.
* Add `<my_daemon>` to `.SUBDIRS` variable in `xen-api/ocaml/OMakefile`.
* Enter `xen-api`'s `chroot`.
* Enter `xen-api`'s directory and compile it with `make`.
* Enter the `<my_daemon>` directory.
* Ensure that global variable `OPTDIR` is defined. If not, define it with
  `export OPTDIR=""`.
* Compile the daemon server by running `omake daemon_server`.
* Compile the daemon client by running `omake daemon_client`.
* Run the test by running `omake test`.
