#!/usr/bin/env sh

CurrentShell=$(ps -o cmd -h $$ | cut -d " " -f 1)

if [ "$0" = "$CurrentShell" ]; then
  _ModuleExecRoot=$(dirname $(realpath $PWD))
else
  _ModuleExecRoot=$(dirname $(realpath $0))
fi

if [ -z "$EnvitRoot" ]; then
  EnvitRoot=$_ModuleExecRoot/.local
  mkdir -p $EnvitRoot
fi

if [ -z "$EnvitProfileRoot" ]; then
  EnvitProfileRoot=$HOME/.envit-profile
  mkdir -p $EnvitProfileRoot
fi

case $1 in
  "build")
    . $_ModuleExecRoot/__envit__/build.sh
    . $_ModuleExecRoot/__envit__/random.sh
    . $_ModuleExecRoot/__envit__/profile.sh

    (
      BeginProfile $EnvitRoot/profiles/tmp${$}_$(RandomHex 16)

      BuildPackage ${2:-.}
      rm -rf $EnvitProfileRoot

      LeaveProfile
    )
    break
    ;;

  "install")
    . $_ModuleExecRoot/__envit__/import.sh
    ImportPackage ${2:-.} $EnvitProfileRoot
    break
    ;;

  "profile-root")
    if [ -z "$EnvitProfiles" ]; then
      echo $EnvitProfileRoot
    else
      echo $EnvitProfiles | cut -d : -f 1
    fi
    break
    ;;

  *)
    cat << EOS
Usage: $(basename $0) build [package]
  Build the package.

Usage: $(basename $0) install [package]
  Install the package.

Usage: $(basename $0) profile-root
  Get the directory of the current profile.

Example: $(basename $0) build
  Build the package from the current directory.

Example: $(basename $0) build ./hoge
  Build packages from other directory.

Example: $(basename $0) build github:foo/bar@v0.1.0
  Build the package from github.
EOS
    break
    ;;
esac