InitProfileDSL() {
  . $_ModuleExecRoot/__envit__/build.sh
  . $_ModuleExecRoot/__envit__/import.sh

  Shell() {
    profile_shell=$1
  }

  ShellHook() {
    profile_shellHook="$*"
  }
}

LoadProfile() {
  InitProfileDSL

  if [ -z "$1" ]; then
    . "$EnvitProfileRoot/profile.envit.sh"
  else
    . "$1"
  fi

  Inputs

  if [ -z "$profile_shell" ]; then
    profile_shell=$SHELL
  fi
}

ExecProfileShell() {(
  rcfile=$(mktemp)

  echo "export EnvitRoot=$EnvitRoot" >> $rcfile
  echo "export EnvitProfileRoot=$EnvitProfileRoot" >> $rcfile
  echo "export EnvitProfiles=$EnvitProfiles" >> $rcfile
  echo 'export PATH="$(echo $EnvitProfiles | sed -E "s/:/\\/bin:/g" | sed -E "s/$/\\/bin/"):$PATH"' >> $rcfile
  echo "export SHELL=\$(which ${profile_shell:-$SHELL})" >> $rcfile
  echo "$profile_shellHook" >> $rcfile

  if [ -p "/dev/stdin" ]; then
    cat - >> $rcfile
    echo . $rcfile | cat - /dev/stdin | env - ${profile_shell:-$SHELL}
  else
    exec env - ${profile_shell:-$SHELL} --rcfile "$rcfile"
  fi

  rm $rcfile
)}

ActivateShell() {(
  source_root=$1
  profile_file=${2:-profile.envit.sh}

  if [ ! -f "$source_root/$profile_file" ]; then
    echo $source_root/$profile_file is not found
    exit 1
    return
  fi

  LoadProfile "$source_root/$profile_file"

  ExecProfileShell
)}

BeginProfile() {
  prev_profile_root=$EnvitProfileRoot
  EnvitProfileRoot=$1

  if [ -z "$EnvitProfiles" ]; then
    EnvitProfiles=$EnvitProfileRoot
  else
    EnvitProfiles=$EnvitProfileRoot:$EnvitProfiles
  fi

  mkdir -p $EnvitProfileRoot

  PATH=$EnvitProfileRoot/bin:$PATH
}

LeaveProfile() {
  PATH=$(echo $PATH | cut -d : -f 2-)
  EnvitProfiles=$(echo $EnvitProfiles | cut -d : -f 2-)

  EnvitProfileRoot=$prev_profile_root
}