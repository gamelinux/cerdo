#! /bin/bash

set -e

check_if_new() {
   old_file=$1
   url=$2
   old_md5=`cat $old_file`
   new_md5=`wget -q $url -O - | sed 's/"//g' | awk '/emerging.rules.tar.gz/ { print $4 }  /^[0-9a-f]/ { print $1 }'`

   # old md5 exists and is same as new
   if [ -n "$old_md5" ]
      then
      if [ "$old_md5" = "$new_md5" ]
         then
         return 1
      fi
   fi
   return 0
}

oink=a68096c6638c17cdce07fb7eb3f28b3d41981304
get_vrt() {
   #oink=9b3c4d511daf586a869c8f8e9447db3449066894
   #oink=268be40015e45f296a928e0a344bf494106ea0fc

   cd /etc/snort
   #wget -q http://www.snort.org/pub-bin/oinkmaster.cgi/$oink/snortrules-snapshot-2.8.tar.gz -O - | tar xzf - 
   wget -q http://www.snort.org/pub-bin/oinkmaster.cgi/$oink/snortrules-snapshot-2853.tar.gz -O - | tar xzf -
}

get_et(){
   wget -q http://www.emergingthreats.net/rules/emerging.rules.tar.gz -O - | tar xzf - 
}

NEW=
if check_if_new /tmp/vrt_md5 http://www.snort.org/pub-bin/oinkmaster.cgi/$oink/snortrules-snapshot-2853.tar.gz.md5
   then
   if get_vrt
      then
      echo $new_md5 > $old_file
      NEW="VRT"
   else
      echo "failed to get VRT" >&2
   fi
fi

if check_if_new /tmp/et_md5 http://www.emergingthreats.net/rules/rules-md5.txt
   then
   if get_et
      then
      echo $new_md5 > $old_file
      NEW="$NEW ET"
   else
      echo "failed to get ET" >&2
   fi
fi

[ -n "$NEW" ] && /etc/init.d/snort reload > /dev/null

