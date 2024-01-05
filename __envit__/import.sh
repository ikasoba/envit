. $_ModuleExecRoot/__envit__/hash.sh
. $_ModuleExecRoot/__envit__/build.sh

ImportPackageFromDirectory() {(
  profile_root=$1
  source_root=$2

  hash=$(PackageHash $source_root/package.envit.sh)

  if [ ! -d "$EnvitRoot/store/$hash" ]; then
    BuildPackageFromDirectory $source_root
  fi

  cp -rsf $EnvitRoot/store/$hash/* $profile_root
)}

ImportPackageFromGithub() {(
  profile_root=$1

  repo_author=$($2 | cut -d "/" -f 1)
  repo_name=$($2 | cut -d "/" -f 2)
  repo_ref=$3

  source_root="$EnvitRoot/git_caches/${repo_author}@${repo_name}"

  if [ ! -d $source_root ]; then
    mkdir -p $EnvitRoot/git_caches/

    git clone https://github.com/${repo_author}/${repo_name} -b $repo_ref $source_root
  fi

  git fetch $repo_ref
  git reset --hard FETCH_HEAD

  hash=$(PackageHash $source_root/package.envit.sh)

  if [ ! -d "$EnvitRoot/store/$hash"]; then
    BuildPackageFromGithub $source_root
  fi

  cp -rl "$EnvitRoot/store/$hash" $profile_root
)}

ImportPackage() {(
  source=$1
  profile_root=${2:-$EnvitProfileRoot}

  echo "Importing package \"$source\""

  case $source in
    "github:")
      ImportPackageFromGithub $profile_root $(echo ${source:7} | tr "@" " ")
      break
      ;;

    *)
      ImportPackageFromDirectory $profile_root $source
      break
      ;;
  esac
)}