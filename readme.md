# envit

envit is a small utility for setting up an environment using only shell scripts.

```sh
# build package from directory
$ envit build ./hoge
# build package from github
$ envit build github:hoge/fuga
# build package from github (with refspec)
$ envit build github:hoge/fuga@v0.1.0
```

For use in environments requiring high availability, it is recommended to use other tools such as nix, docker, podman, etc.

# dependencies
- git (optional)
- sh

# Installation

```sh
$ git clone https://github.com/ikasoba/envit
$ cd envit
$ ./scripts/install-envit.sh
$ cd ..
```

# Package Creation

## Create `package.envit.sh`

example:
```sh
Name "my-package"
Version "0.1.0"
Description ...

# Specify files required at build time
# This can be multiple or single files as well as directories.
Source my-command.sh hoge fuga

# Functions for collecting dependencies
Inputs() {
  # ImportPackage can install packages from directories or github repositories
  # example: ImportPackage ./hoge
  ImportPackage github:hoge/fuga@v0.1.0
}

# Functions for Build
# Note: The program is executed in the directory where only the necessary files are copied, not in the root directory of the package.
Build() {
  mkdir -p bin
  mv my-command.sh bin/my-command
  chmod +x bin/my-command
}

# Specify build artifacts
Outputs() {
  # This can be a file as well as a directory
  Output bin
}
```

# Creating a Shell Environment
## Create `profile.envit.sh`
```sh
# Hooks executed at shell startup
ShellHook '
  export PS1="\w> "
  echo Hello, world!
'

# Functions for collecting dependencies
Inputs() {
  # Specify the package you want to add to the shell's environment
  ImportPackage github:hoge/fuga@v0.1.0
}
```

## Execute shell environment
```sh
$ envit-shell
```