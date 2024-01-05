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

. $_ModuleExecRoot/__envit__/hash.sh
. $_ModuleExecRoot/__envit__/profile.sh

case $1 in
  "-")
    (
      tmpProfile=$(mktemp -d)
      BeginProfile $tmpProfile
      cat $2 | ExecProfileShell
      LeaveProfile
    )
    break
    ;;

  "-h" | "--help" | "?")
    cat << EOS
Usage: $(basename $0) <directory>
  Generate a development environment and run a shell.

Usage: $(basename $0) - <file>
  Run shell scripts in temporary profiles.
EOS
    break
    ;;

  *)
    (
      BeginProfile "$EnvitRoot/profiles/dev_$(echo $PWD | Sha256Hash)"
      ActivateShell ${1:-.} $2
      LeaveProfile
    )
    break
    ;;
esac