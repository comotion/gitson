#!/bin/bash 
#
#  * git pull every repo under zones/
#  * cat all files
#  * run tinydns-data
#
#  TODO
#  * some sort of validation
#    * accept new domains, but not duplicates
#    * ensure that files only contain domains matching filename
#

# in-addr
#   cat zones/192-26.36.158.in-addr.arpa | grep -E '^\^' | cut -d: -f1 | sed "s/(\\057|\/)/-/g" | cut -d. -f 2-
#   Z
# else
#   cat zones/radionova.no | grep -E '^(=|\+|6|C|\&|\@|\.)' | cut -d: -f1 | awk -F'.' '{print $(NF-1) "." $NF}' | sed 's/[^a-zA-Z.]//g'
#

run_command () {
  result=$($* 2>&1)
  rcode=$?
  if [ ! $rcode -eq 0 ] ; then
    echo $result
    exit $rcode 
  fi
}

shopt -s globstar

startdir=$(pwd)
scriptdir=$(dirname $(readlink -f $0))
user=$(stat -c "%U" "$scriptdir/data.cdb")

if [ ! x$user == x$USER ] ; then
  echo "Run me as $user, please."
  exit 1
fi

cd $scriptdir

# git config, motherfucker
# who gives a fucking shit ass vagina
git config --global user.name penis
git config --global user.email penis

for i in zones/** ; do
  if [ -d $i/.git ]; then
    cd $i
    run_command git pull 
    cd $scriptdir
  fi
done

echo -n > data
for i in zones/** ; do
  if [ -f $i ]; then
    cat $i >> data
  fi
done

run_command /usr/local/bin/tinydns-data

cd $startdir
