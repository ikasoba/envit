Run() {
  if [ "$_envit_command_runAnyOne" = 1 ]; then
    ($*) 1> $_envit_command_last_command_output 2> $_envit_command_last_command_output
  else
    $*
  fi

  if [ "$?" != 0 ]; then
    if [ "$_envit_command_runAnyOne" = 1 ]; then
      _envit_command_last_command="$*"
    else
      echo "failed execute: $*"
      exit 1
    fi
  else
    _envit_command_last_command=
  fi
}

BeginRunAnyOne() {
  _envit_command_runAnyOne=1
  _envit_command_last_command_output=$(mktemp)
}

EndRunAnyOne() {
  _envit_command_runAnyOne=0

  if [ ! -z "$_envit_command_last_command" ]; then
    cat $_envit_command_last_command_output
    echo "failed execute: $_envit_command_last_command"
    rm $_envit_command_last_command_output
    exit 1
  fi

  rm $_envit_command_last_command_output
  _envit_command_last_command_output=
}