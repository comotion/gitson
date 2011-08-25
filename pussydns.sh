#!/bin/sh
#
#  * git pull every repo under zones/
#  * validate all files
#  * run tinydns-data
#
#  * some sort of validation - check
#    * ensure that files only contain domains matching filename - check
#  TODO
#    * accept new domains, but not duplicates
#    * deal with data.cdb timestamps so we don't update needlessly
#
# krav/comotion 2011-06-02

# in-addr
#   cat zones/192-26.36.158.in-addr.arpa | grep -E '^\^' | cut -d: -f1 | sed "s/(\\057|\/)/-/g" | cut -d. -f 2-
#   Z
# else
#   cat zones/radionova.no | grep -E '^(=|\+|6|C|\&|\@|\.)' | cut -d: -f1 | awk -F'.' '{print $(NF-1) "." $NF}' | sed 's/[^a-zA-Z.]//g'
#

ZONES=zones/

VALREV= #don't validate reverse zones

run_command () {
  result=$($* 2>&1)
  rcode=$?
  if [ ! $rcode -eq 0 ] ; then
    echo $result
    exit $rcode 
  fi
}

startdir=$(pwd)
scriptdir=$(dirname $0)
user=$(stat -c "%U" "$startdir/data.cdb")

if [ "$user" != "$USER" ] ; then
  echo "Run me as $user, please."
  exit 1
fi

cd $startdir

VALIDZONES=""
for i in `find $ZONES -mindepth 1 -type d | grep -v '/\.'`
do
  #echo "zone: $i"
  # zones are dirs containing my.domain.org files
  if [ "$1" != "nopull" -a -d $i/.git ]; then
    cd $i
    run_command git pull 
    cd $startdir
  fi
  for domainfile in `find $i -type f | grep -v '/\.'`
  do
    NVALID=
    domain=`basename $domainfile`
    egrep -v '^\s*#|^\s*$' $domainfile | 
    # note even without the parens it's a bloody subshell m'kay? 
    ( while read LINE
      do
        DOMAIN=`echo $LINE | sed 's/^.//' | cut -f 1 -d : | sed 's/\.$//'`
        if echo "$DOMAIN" | grep -q "$domain$"
          then
          : #HAPPY CAMPER
        elif echo $DOMAIN | grep -q in-addr.arpa$
          then
          REVERSE=`echo $LINE | sed 's/^.//' | cut -f 2 -d : | sed 's/\.$//'`
          #echo "REVERSE $DOMAIN $REVERSE"
          if [ -n "$VALREV" ] && ! echo "$REVERSE" | grep -q "$domain$"
            then
            # not really validation of IP domain control
            echo "$REVERSE delegated outside of $domain"
            NVALID="$NVALID $REVERSE"
          fi
        else
          echo "$DOMAIN should not be in $domain" >&2
          NVALID="$NVALID $DOMAIN"
        fi
      done
      [ -n "$NVALID" ] && exit 23
    ) 
    # dont fuck with exit status between these two lines ^-v
    if [ $? = 23 ]
      then
      echo "$domainfile invalid, rejecting."
    else
      # does it already exist?. need to find subdomains too
      if echo $VALIDZONES | grep -q `basename $domainfile`
        then
        : do something
      fi

      VALIDZONES="$VALIDZONES $domainfile"
    fi
  done
       
done

#echo $VALIDZONES
echo -n > data
[ -n "$VALIDZONES" ] && cat $VALIDZONES >> data || echo "NO VALID ZONES" >&2

run_command /usr/local/bin/tinydns-data

cd $startdir
