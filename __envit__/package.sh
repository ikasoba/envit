InitPackageDSL() {
  . $_ModuleExecRoot/__envit__/build.sh
  . $_ModuleExecRoot/__envit__/import.sh
  . $_ModuleExecRoot/__envit__/download.sh

  Name() {
    package_name=$1
  }
  
  Version() {
    package_version=$1
  }
  
  Description() {
    package_description=$1
  }
  
  Main() {
    package_main=$1
  }

  Source() { return; }
}