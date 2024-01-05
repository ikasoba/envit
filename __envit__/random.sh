RandomHex() {
  head /dev/random -c $1 | xxd -ps -c $1
}