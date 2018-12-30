#!/bin/sh
# test for init



testout1=$( perl legit.pl init )
testout2=$( perl legit.pl init 2>&1 )



ans='Initialized empty legit repository in .legit';
ans2='legit.pl: error: .legit already exists';
echo "test begin>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ "$ans" = "$testout1" ]; then
  echo "1-init-pass"
else
  echo "1-init-fail"
fi
#echo $testout1
if [ "$ans2" = "$testout2" ]; then
  echo "2-rundinit-pass"
else
  echo "2-rundinit-fail"
fi
#echo $testout2
if  test -e '.legit/index' ; then
  echo "3-create-index-pass"
else
  echo "3-create-index-fail"
fi

if  test -e '.legit/del' ; then
  echo "4-create-del-pass"
else
  echo "4-create-del-fail"
fi

if test -e '.legit/master'; then
  echo "5-create-master-pass"
else
  echo "5-create-master-fail"
fi
if test -e '.legit/staged'; then
  echo "6-create-staged-pass"
else
  echo "6-create-staged-fail"
fi


echo ""
rm -rf .legit
