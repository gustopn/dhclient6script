BEGIN { RS = "\n"; FS = " " }
{
 if ( $1 == "inet6" ) {
   split($2, addrsplit, "")
   if ( addrsplit[1] != "f" )
     print $2
 }
}
