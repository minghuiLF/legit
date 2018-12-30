#!/bin/sh
#test for log
#

ans='Initialized empty legit repository in .legit';


echo "test begin>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
## 1 init
testout1=$( perl legit.pl init )
echo "a1" > a


## 1 init
if [ "$ans" = "$testout1" ]; then
  echo "1-init-pass"
else
  echo "1-init-fail"
fi


# 2 empty log
testout2=$(perl legit.pl log 2>&1)
ans2="legit.pl: error: your repository does not have any commits yet"
# 2 empty log
if [ "$ans2" = "$testout2" ];
then
  echo "2-empty-log-pass"
else
  echo "2-empty-log-fail"
fi
# 2 normal log
perl legit.pl add a
testout=$(perl legit.pl commit -m "message000")
echo "0 message000" > testlog
echo "new_a" >> a
perl legit.pl add a
testout=$(perl legit.pl commit -m "message111")
echo "1 message111" >> testlog
testout3=$(cat '.legit/master/log')

ans3=$(cat testlog)

# 2 normal log
if [ "$ans3" = "$testout3" ];
then
  echo "3-normal-log-pass"
else
  echo "3-normal-log-fail"
fi


echo ""
rm -rf .legit
rm testlog a
