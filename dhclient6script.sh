#!/bin/ksh -x
configured_interfaces_list="cnmac0 cnmac2"
src_dir="/root/bin/iscdhclient6/src"

find_configured_addrs() {
  if [ "$#" -eq 1 ]
  then \
    ifconfig "$1" inet6 | awk -f "$src_dir/getConfiguredGlobalIPaddrs.awk"
  fi
}

find_configured_nameservers() {
  cat /var/unbound/etc/forward_all.conf | awk -f "$src_dir/getNameserversV6.awk"
}

create_prefixed_addrs() {
  set -x
  if [ "$#" -eq 2 ]
  then \
    devsum=`echo -n "$1" | md5 | tr -d '\n'`
    echo "$2" | awk -v hintvar="$devsum" -f "$src_dir/getUsablePrefixAddrV6.awk"
  fi
}

configure_prefixed_addrs() {
  set -x
  if [ "$#" -eq 2 ]
  then \
    ifconfig "$1" inet6 "$2" eui64 alias
    ifconfig "$1" inet6 "${2}1" alias
  fi
}

er_dhcpv6_bind() {
  set -x
  if [ -z "$new_ip6_prefix" ]
  then \
    return 1
  fi
  configured_nameservers=`find_configured_nameservers`
  prefixtoconfigure=`echo "$new_ip6_prefix" | awk -f "$src_dir/getUsablePrefixAddrV6.awk"`
  if [ -n "$prefixtoconfigure" ]
  then \
    for configured_interface in $configured_interfaces_list
    do \
      configured_addrs=`find_configured_addrs "$configured_interface"`
      if [ -z "$configured_addrs" ]
      then \
	configure_prefixed_addrs "$configured_interface" `create_prefixed_addrs "$configured_interface" "$new_ip6_prefix"`
      else
        configured_addrs_status=`echo $configured_addrs | awk -v prefix=$prefixtoconfigure -f "$src_dir/checkConfiguredAddrV6.awk"`
        if [ "failure" == "$configured_addrs_status" ]
        then \
          for configured_addr in $configured_addrs
          do \
	    ifconfig $configured_interface inet6 $configured_addr -alias
          done
	  configure_prefixed_addrs "$configured_interface" `create_prefixed_addrs "$configured_interface" "$new_ip6_prefix"`
        fi
      fi
    done
  fi
}

case $reason in 
	( 'BOUND6' | 'REBIND6' ) er_dhcpv6_bind ;;
	( 'RENEW6' ) ;;
	( * ) echo "WTF's that?";;
esac
