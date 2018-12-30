#!/bin/sh
#test for commit
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

# 2 empty commit
testout2=$(perl legit.pl commit -m "message")
ans2="nothing to commit"
# 2 empty commit
if [ "$ans2" = "$testout2" ];
then
  echo "2-empty-commit-pass"
else
  echo "2-empty-commit-fail"
fi



# 3 nomal commit
perl legit.pl add a
testout3=$(perl legit.pl commit -m "message")
ans3="Committed as commit 0"
# 3 nomal commit
if [ "$ans3" = "$testout3" ]
!(test -e '.legit/staged/a')
test -e '.legit/master/.0'
then
  echo "3-nomal commit-pass"
else
  echo "3-nomal commit-fail"
fi

# 4 commit rm (include unix rm)

perl legit.pl rm a
testout4=$(perl legit.pl commit -m "message1")
ans4="Committed as commit 1"
# 4 add a same file
if [ "$ans4" != "$testout4" ]
test -e '.legit/master/.1/a'
grep -q "a" '.legit/del'
then
  echo "4-commit-rm -fail"
else
  echo "4-commit-rm -pass"
fi










echo ""
rm -rf .legit
