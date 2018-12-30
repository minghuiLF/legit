#!/bin/sh
#test for status
#

ans='Initialized empty legit repository in .legit';


echo "test begin>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
## 1 init
testout1=$( perl legit.pl init )



## 1 init
if [ "$ans" = "$testout1" ]; then
  echo "1-init-pass"
else
  echo "1-init-fail"
fi

touch a b c d e f g h
perl legit.pl add a b c d e f
testout=$(perl legit.pl commit -m "message0")
echo a1 >a
echo b1 >b
echo c1 >c
 perl legit.pl add a b
echo a2 > a
rm d
perl legit.pl rm e
perl legit.pl add g

testout2=$(perl legit.pl status|egrep "^\w\s")
echo 'a - file changed, different changes staged for commit' >> testoutfile
echo 'b - file changed, changes staged for commit' >> testoutfile
echo 'c - file changed, changes not staged for commit' >> testoutfile
echo 'd - file deleted' >> testoutfile
echo 'e - deleted' >> testoutfile
echo 'f - same as repo' >> testoutfile
echo 'g - added to index' >> testoutfile
echo 'h - untracked' >> testoutfile
ans2=$(cat testoutfile)


if [ "$ans2" = "$testout2" ]; then
  echo "2-status-pass"
else
  echo "2-status-fail"
fi


echo ""
rm -rf .legit
rm a b c f g h testoutfile
