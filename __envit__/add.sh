. $_ModuleExecRoot/__envit__/import.sh

AddPackage() {
  source=$1
  profile_root=${2:-$EnvitProfileRoot}

  cp $profile_root/profile.envit.sh $profile_root/profile.envit.sh.backup

  awk -v source=${source} '
    BEGINFILE {
      b = 0
      ignore = 0
    }

    /Inputs()\s*{/ {
      b = 1
    }

    /ImportPackage/ {
      if ($2 == source) {
        ignore = 1
      } else {
        ignore = 0
      }
    }

    /}/ {
      b=2
    }

    {
      if (b == 2) {
        printf "  ImportPackage %s\n", source
        print $0
        b = 0
      } else if (ignore == 0) {
        print $0
      }
    }
  ' $profile_root/profile.envit.sh.backup > $profile_root/profile.envit.sh

  ImportPackage $source $profile_root
}