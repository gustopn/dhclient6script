BEGIN { RS = "\n"; FS = "/" }
{
  paddr = $1
  plen = $2
  ncut = int( (64 - plen) / 4 )
  split(paddr, paddrparts, ":")
  partstokeep = int( plen / 16 )
  paddr = ""
  for ( i=1; i<=partstokeep; i++ ) {
    paddr = paddr "" paddrparts[i] ":"
  }
  split(paddrparts[partstokeep+1], plastpart, "")
  lastpartkeep = length(paddrparts[partstokeep+1]) - ncut
  for ( i=1; i<=lastpartkeep; i++ ) {
    paddr = paddr "" plastpart[i]
  }
  split(hintvar, hint, "")
  if ( length(hint) >= ncut ) {
    newhint = ""
    for ( i=( length(hint) - ncut + 1 ); i<=( length(hint) ); i++ ) {
      newhint = newhint "" hint[i]
    }
    paddr = paddr "" newhint
    print paddr "" "::"
  } else {
    print paddr
  }
}
