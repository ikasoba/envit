#!/usr/bin/env sh

CurrentShell=$(basename $(ps -o cmd -h $$ | cut -d " " -f 1))

if [ "$0" = "$CurrentShell" ]; then
  _ModuleExecRoot=$(dirname $(realpath $PWD))
else
  _ModuleExecRoot=$(dirname $(realpath $0))
fi

PosixShellStartup() {
  echo '# begin envit configuration'
  echo 'export EnvitRoot="'$EnvitRoot'"'
  echo 'export EnvitProfileRoot="$HOME/.envit-profile"'
  echo 'export EnvitProfiles="$EnvitProfileRoot"'
  echo 'export PATH="$(echo $EnvitProfiles | sed -E "s/:/\\/bin:/g" | sed -E "s/$/\\/bin/"):$PATH"'
  echo '# end envit configuration'
}

case $CurrentShell in
  "bash" | "dash" | "ash" | "sh")
    if [ -z "$EnvitRoot" ]; then
      EnvitRoot=$(realpath $_ModuleExecRoot/../.local)
      mkdir -p $EnvitRoot
    fi

    if [ -z "$EnvitProfileRoot" ]; then
      EnvitProfileRoot=$HOME/.envit-profile
      mkdir -p $HOME/.envit-profile
    fi

    cat << EOS > $EnvitProfileRoot/profile.envit.sh
Inputs() {
  ImportPackage $(realpath $_ModuleExecRoot/..)
}
EOS

    echo Add setup process to ~/.profile
    PosixShellStartup >> ~/.profile

    eval $(PosixShellStartup)

    echo Building envit
    $_ModuleExecRoot/../envit.sh build $(realpath $_ModuleExecRoot/..)
    echo Done

    echo Setup Profile
    $_ModuleExecRoot/../envit-env.sh build $EnvitProfileRoot
    echo Done
    break
    ;;

  *)
    echo $CurrentShell is not supported.
    exit 1
    break
    ;;
esac
