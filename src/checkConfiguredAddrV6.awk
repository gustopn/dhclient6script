# the var prefix must be set to the prefix we look for in every ip6 addr on input
{
  if ( length(prefix) > 0 ) {
    paddr = substr($1, 0, length(prefix))
    if ( prefix != paddr ) {
      print "failure"
      exit 1
    }
  }
}
# output is nothing, when it goes well, and if not, it prints failure, for what
# we can check with an if, if the output strnig is empty when OK.
