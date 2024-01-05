. $_ModuleExecRoot/__envit__/hash.sh
. $_ModuleExecRoot/__envit__/build.sh
. $_ModuleExecRoot/__envit__/command.sh

ImportPackageFromDirectory() {(
  profile_root=$1
  source_root=$2

  hash=$(PackageHash "$source_root" package.envit.sh)

  if [ ! -d "$EnvitRoot/store/$hash" ]; then
    BuildPackageFromDirectory $source_root
  fi

  for item in $(find $EnvitRoot/store/$hash/ -type f)
  do
    base=$(dirname $item | cut -c $(echo $EnvitRoot/store/$hash/ | wc -c)-)
    echo - $base
    exit 1
  done
)}

ImportPackageFromGithub() {(
  profile_root=$1

  repo_author=$(echo $2 | cut -d "/" -f 1)
  repo_name=$(echo $2 | cut -d "/" -f 2)
  repo_ref=$3
  repo_path=$4

  source_root="$EnvitRoot/gh_caches/$repo_author@$repo_name"

  if [ ! -d "$source_root" ]; then
    mkdir -p $EnvitRoot/gh_caches/

    Run git clone -b $repo_ref https://github.com/$repo_author/$repo_name $source_root
  fi

  (
    cd $source_root

    Run git fetch
    Run git reset --hard $repo_ref
  )

  hash=$(PackageHash "$source_root" package.envit.sh)

  store_root=$EnvitRoot/store/$hash/

  if [ ! -d "$store_root" ]; then
    BuildPackageFromDirectory "$source_root"
  fi

  for item in $(find $store_root -type f)
  do
    relative_path=$(echo $item | cut -c $(echo $store_root | wc -c)-)
    base=$(dirname "$relative_path")

    mkdir -p $profile_root/$base

    if [ -e "$profile_root/$relative_path" ]; then
      rm -f $profile_root/$relative_path
    fi

    BeginRunAnyOne
      Run cp -lf $item $profile_root/$base
      Run cp -Lf $item $profile_root/$base
    EndRunAnyOne
  done
)}

ImportPackage() {(
  source=$1
  profile_root=${2:-$EnvitProfileRoot}

  echo "Importing package \"$source\""

  case $(echo $source | cut -c 1-7) in
    "github:")
      (
        full=$(echo $source | cut -c 8-)
        repo=$(echo $full | awk -F @ '{ print $1 }')
        repo_ref=$(echo $full | awk -F @ '{ print $2 }')
        repo_path=$(echo $repo_ref | awk -v RS=/ -v ORS=/ 'NR > 1 { print $1 }' | sed 's/\/$//')
        repo_ref=$(echo $repo_ref | awk -F / '{ print $1 }')

        if [ -z "$repo_ref" ]; then
          echo refspec is not specified
          exit 1
        fi

        ImportPackageFromGithub $profile_root $repo $repo_ref $repo_path
      )
      break
      ;;

    *)
      ImportPackageFromDirectory $profile_root $source
      break
      ;;
  esac
)}