Name "envit"
Version "0.1.3"
Description "Small utilities to set up the environment"

Source __envit__ envit.sh envit-shell.sh envit-env.sh

Inputs() { return; }

Build() {
  mkdir -p bin
  mv __envit__ bin/__envit__

  mv envit.sh bin/envit
  chmod +x bin/envit

  mv envit-shell.sh bin/envit-shell
  chmod +x bin/envit-shell

  mv envit-env.sh bin/envit-env
  chmod +x bin/envit-env
}

Outputs() {
  Output bin
}