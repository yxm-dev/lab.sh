# About

This repository contains a CLI to manage the [lab](https://lab.yxm.me) project. 

# Install

1. Clone the repository:
```bash
    git clone https://github.com/yxm-dev/lab.sh
``` 
2. Enter in the `install` directory and execute then `configure` script to set the installation directory:
```bash
    cd lab.sh/install
    ./configure
```
3. Execute the `install`: 
```bash
    ./install
```

To uninstall `lab`, execute the `uninstall` script or call the `--uninstall` option.

# Dependencies

The dependencies are the following, which should be automatically installed when executing the `install`
script:

* [git](https://git-scm.com/)
* [sed](https://www.gnu.org/software/sed/)
* [pandoc](https://github.com/jgm/pandoc)
* [rsync](https://github.com/WayneD/rsync).

# Usage

```
usage: lab [options] [arguments]     (general case)
   or: lab                           print this help message or open the
                                                          [lab directory 

options:
    --config                          enter in the configuration mode
    -h, --help                        display this help message
    --info                            display info on how to contribute
    -n, --new                         create a new QA, doc, def or ref file
    -i, --index                       update the indexes
    -c, --convert                     convert the files from md to html
    -p, --push
        md, markdown                  push the markdown files
        html                          push the html files

aliases:
    labi = lab -i
    labc = lab -c
    labp = follow the entire push pipeline
```

# Configuration

* After installed, `lab` must be configured before first usage: *execute `lab --config`*.

The configuration is made through the following environment variables stored in a `.env` file:
* `LAB_INSTALL`: the directory where the `lab.sh` is installed. This is fixed in the installation step when
  executing the `configure` script.
* `LAB`: the directory where the `.md` files will be located. It is where the contributor will enter to 
  create new QA, etc.
* `LAB_MD` and `LAB_HTML`: locations where the [lab](https://codeberg.org/yxm/lab) and 
  [lab.md](https://codeberg.org/yxm/lab.md) repositories are cloned. By default they are cloned in
  `$LAB_INSTALL/git` when executing the `install` script.
* `LAB_NAME`: the contributor's full name. Used to create the branch in which the contributor will work in and,
  in future, to build the contributors page.
* `LAB_BRANCH`: the contributor's branch. Constructed from `$LAB_NAME` in the `lab --config` step.

# To Do

* Automatically create a contributors page;
* Add a full text search feature;
* Automatically provide a `.pdf` with all `QA`.
