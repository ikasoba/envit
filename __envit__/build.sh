. $_ModuleExecRoot/__envit__/hash.sh
. $_ModuleExecRoot/__envit__/package.sh

BuildPackageFromDirectory() {(
  source_root=$1

  hash=$(PackageHash $source_root/package.envit.sh)

  if [ -d "$EnvitRoot/store/$hash" ]; then
    echo "rebuilding $hash"
    rm -rf $EnvitRoot/store/$hash/*
  fi

  output_root=$EnvitRoot/working/$hash
  mkdir -p $output_root

  InitPackageDSL

  Source() {
    cp -r $* $output_root
  }

  . $source_root/package.envit.sh

  Inputs

  source_root=$output_root

  (
    cd $source_root

    out=.
    Build

    output_root="$EnvitRoot/store/$hash"
    out=$output_root
    mkdir -p $output_root

    Output() {
        mv $* $output_root
    }

    Outputs

    rm -rf $source_root
  )

  echo "build succeeded"
)}

BuildPackageFromGithub() {(
  repo_author=$($1 | cut -d "/" -f 1)
  repo_name=$($1 | cut -d "/" -f 2)
  repo_ref=$2

  source_root=$EnvitRoot/git_caches/${repo_author}@${repo_name}

  if [ ! -d source_root ]; then
    mkdir -p $EnvitRoot/git_caches/

    git clone https://github.com/${repo_author}/${repo_name} -b $repo_ref $source_root
  fi

  git fetch $repo_ref
  git reset --hard FETCH_HEAD

  BuildPackageFromDirectory $source_root
)}

BuildPackage() {
  case $1 in
    "github:")
      BuildPackageFromGithub $(echo ${1:7} | tr "@" " ")
      break
      ;;

    *)
      BuildPackageFromDirectory $1
      break
      ;;
  esac
}