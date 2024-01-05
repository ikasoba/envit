. $_ModuleExecRoot/__envit__/package.sh

Sha256Hash() {
  sha256sum | cut -d " " -f 1
}

DirectoryHash() {
  find $1 -type f -exec sha256sum {} \; | awk '{ print $1 }' | Sha256Hash
}

BulkHash() {
  for item in $*
  do
    if [ -f "$item" ]; then
      cat $item | Sha256Hash
    elif [ -d "$item" ]; then
      DirectoryHash $item
    fi
  done
}

PackageHash() {(
  source_root=$1

  InitPackageDSL

  Source() {
    hash=$(BulkHash $(echo $* | xargs -d " " -I: echo $source_root/:) | Sha256Hash)
  }

  . $source_root/$2

  if [ -z "$hash" ]; then
    hash=$(BulkHash $source_root)
  fi

  echo "${hash}_${package_name}_${package_version}"
)}