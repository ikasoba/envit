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
  "build")
    (
      echo Build $EnvitProfileRoot
      BeginProfile ${2:-$EnvitProfileRoot}
      LoadProfile
      LeaveProfile
    )
    break
    ;;

  *)
    cat << EOS
Usage: $(basename $0) build
  Build environment from current profile

Usage: $(basename $0) build <directory>
  Build profiles from the directory
EOS
    break
    ;;
esac