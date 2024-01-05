. $_ModuleExecRoot/__envit__/package.sh

Sha256Hash() {
  sha256sum | cut -d " " -f 1
}

DirectoryHash() {
  find $1 -type f -exec sha256sum {} \; | sed -E 's/\s*-//g' | Sha256Hash
}

BulkHash() {
  for item in $*
  do
    if [ -f item ]; then
      cat $item | Sha256Hash
    elif [ -d item ]; then
      DirectoryHash $item
    fi
  done
}

PackageHash() {(
  InitPackageDSL

  Source() {
    hash=$(BulkHash $* | Sha256Hash)
  }

  if [ -z $hash ]; then
    hash=$(DirectoryHash $source_root)
  fi

  . $1

  echo "${hash}_${package_name}_${package_version}"
)}