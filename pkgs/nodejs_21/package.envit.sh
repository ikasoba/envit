Name "nodejs"
Version "21.5.0"
Description "nodejs v21 package for envit"

Inputs() { return; }

Build() {
  case $(uname -s | tr [:upper:] [:lower:]) in
    "linux")
      os=linux
      break
      ;;

    "darwin")
      os=darwin
      break
      ;;

    *)
      echo unspported platform
      exit 1
      break
      ;;
  esac

  case $(uname -m | tr [:upper:] [:lower:]) in
    "x86_64" | "amd64")
      arch=x64
      break
      ;;

    "arm64")
      arch=arm64
      break
      ;;

    "armv7l")
      arch=armv7l
      break
      ;;

    "i386" | "x86")
      arch=x86
      break
      ;;

    *)
      echo unspported architecture
      exit 1
      break
      ;;
  esac

  DownloadFile https://nodejs.org/dist/v$package_version/node-v$package_version-$os-$arch.tar.gz node-v$package_version-$os-$arch.tar.gz
  tar -zxvf node-v$package_version-$os-$arch.tar.gz --strip-component 1 node-v$package_version-$os-$arch/bin node-v$package_version-$os-$arch/lib node-v$package_version-$os-$arch/share
}

Outputs() {
  Output bin
  Output lib
  Output share
}