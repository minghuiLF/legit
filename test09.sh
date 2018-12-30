#!/bin/sh
#test for subset0
#

ans='Initialized empty legit repository in .legit';


echo "test begin>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
## 1 init
testout1=$( perl legit.pl init )



## 1 init
if [ "$ans" = "$testout1" ]; then
  echo "1-subset0-pass"
else
  echo "1-subset0-fail"
fi

echo line 1 > a
echo hello world >b
perl legit.pl add a b
testout2=$(perl legit.pl commit -m 'first commit')
ans2='Committed as commit 0'
if [ "$ans2" = "$testout2" ]; then
  echo "2-subset0-pass"
else
  echo "2-subset0-fail"
fi

echo  line 2 >>a
perl legit.pl add a
testout3=$(perl legit.pl commit -m 'second commit')
ans3='Committed as commit 1'

if [ "$ans3" = "$testout3" ]; then
  echo "3-subset0-pass"
else
  echo "3-subset0-fail"
fi

log=$(perl legit.pl log)
echo "1 second commit" > testlog
echo "0 first commit" >> testlog
ans=$(cat testlog)

if [ "$log" = "$ans" ]; then
  echo "4-subset0-pass"
else
  echo "4-subset0-fail"
fi

echo line 3 >>a
perl legit.pl add a
echo line 4 >>a

a1=$(perl legit.pl show 0:a)
a2=$(perl legit.pl show 1:a)
a3=$(perl legit.pl show :a)

echo "line 1" >testa1
echo "line 1" >testa2
echo "line 1" >testa3
echo "line 2" >> testa2
echo "line 2" >> testa3
echo "line 3" >> testa3

ta1=$(cat testa1)
ta2=$(cat testa2)
ta3=$(cat testa3)

if [ "$a1" = "$ta1" ]
[ "$a2" = "$ta2" ]
[ "$a3" = "$ta3" ]
then
  echo "5-subset0-pass"
else
  echo "5-subset0-fail"
fi


echo ""
rm -rf .legit
rm testa1 testa2 testa3 testlog
