. $_ModuleExecRoot/__envit__/hash.sh
. $_ModuleExecRoot/__envit__/package.sh
. $_ModuleExecRoot/__envit__/command.sh

BuildPackageFromDirectory() {(
  source_root=$1

  hash=$(PackageHash "$source_root" package.envit.sh)

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
  repo_author=$(echo $1 | cut -d "/" -f 1)
  repo_name=$(echo $1 | cut -d "/" -f 2)
  repo_ref=$2
  repo_path=$3

  source_root=$EnvitRoot/gh_caches/$repo_author@$repo_name

  if [ ! -d "$source_root" ]; then
    mkdir -p $EnvitRoot/gh_caches/

    Run git clone -b $repo_ref https://github.com/${repo_author}/${repo_name} $source_root
  fi

  (
    cd $source_root

    Run git fetch
    Run git reset --hard $repo_ref
  )

  BuildPackageFromDirectory $source_root/$repo_path
)}

BuildPackage() {
  case $(echo $1 | cut -c 1-7) in
    "github:")
      (
        full=$(echo $1 | cut -c 8-)
        repo=$(echo $full | awk -F @ '{ print $1 }')
        repo_ref=$(echo $full | awk -F @ '{ print $2 }')
        repo_path=$(echo $repo_ref | awk -v RS=/ -v ORS=/ 'NR > 1 { print $1 }' | sed 's/\/$//')
        repo_ref=$(echo $repo_ref | awk -F / '{ print $1 }')

        if [ -z "$repo_ref" ]; then
          echo refspec is not specified
          exit 1
        fi

        BuildPackageFromGithub $repo $repo_ref $repo_path
      )
      break
      ;;

    *)
      BuildPackageFromDirectory $1
      break
      ;;
  esac
}