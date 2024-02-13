. $_ModuleExecRoot/__envit__/command.sh

CopyDirectory() {
  src=$1
  target=$2

  for item in $(find $src -type f)
  do
    relative_path=$(echo $item | cut -c $(echo $src | wc -c)-)
    base=$(dirname "$relative_path")

    mkdir -p $target/$base

    if [ -e "$target/$relative_path" ]; then
      rm -f $target/$relative_path
    fi

    (BeginRunAnyOne
      Run cp -lf $item $target/$base
      Run cp -Lf $item $target/$base
    EndRunAnyOne) > /dev/null
  done

  echo Done
}