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
  echo 'export PATH="$(echo $EnvitProfiles | sed -E "s/:/\\/bin:/g" | sed -E "s/\$/\\/bin/"):$PATH"'
  echo '# end envit configuration'
}

case $CurrentShell in
  "bash" | "dash" | "ash" | "sh")
    if [ -z "$EnvitRoot" ]; then
      EnvitRoot=$(realpath $_ModuleExecRoot/../.local)
    fi

    mkdir -p $EnvitRoot

    if [ -z "$EnvitProfileRoot" ]; then
      EnvitProfileRoot=$HOME/.envit-profile
    fi

    mkdir -p $HOME/.envit-profile

    cat << EOS > ${EnvitProfileRoot}/profile.envit.sh
Inputs() {
  ImportPackage $(realpath $_ModuleExecRoot/..)
}
EOS

    read -p "Remove previously configured settings for envit from ~/.profile [y/n] " ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
      filtered=$(mktemp)

      awk -F"\n" '
        BEGIN {
          b=1
        }

        /# begin envit configuration/ {
          b=0
        }

        /# end envit configuration/ {
          b=2
        }

        {
          if (b == 2) {
            b = 1
          } else if (b == 1) {
            print $0
          }
        }
      ' ~/.profile > $filtered

      echo Backups of ~/.profile are generated to ~/.profile.envit.backup
      cat ~/.profile > ~/.profile.envit.backup
      cat $filtered > ~/.profile
      rm $filtered
      echo Done
    fi

    echo Add setup process to ~/.profile
    PosixShellStartup >> ~/.profile

    eval $(PosixShellStartup)

    echo Building envit
    sh $_ModuleExecRoot/../envit.sh build $(realpath $_ModuleExecRoot/..)
    echo Done

    echo Setup Profile
    sh $_ModuleExecRoot/../envit-env.sh build $EnvitProfileRoot
    echo Done
    break
    ;;

  *)
    echo $CurrentShell is not supported.
    exit 1
    break
    ;;
esac
