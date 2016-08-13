{
  if ( $1 != "#" ) {
    if ( $1 == "forward-addr:" ) {
      split($2, ipaddrparts, ":")
      if ( length(ipaddrparts) > 4 )
        print $2
    }
  }
}
