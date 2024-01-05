DownloadFile() {
  url=$1
  out=$2

  if command -v curl > /dev/null; then
    curl -L -o $out $url
  elif command -v wget > /dev/null; then
    wget -O $out $url
  else
    echo curl or wget is not installed.
    exit 1
  fi
}