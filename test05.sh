#!/bin/sh
#test for show
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

# 2 empty show
testout2=$(perl legit.pl show 0:a 2>&1)
ans2="legit.pl: error: your repository does not have any commits yet"
# 2 empty show
if [ "$ans2" = "$testout2" ];
then
  echo "2-empty-show-pass"
else
  echo "2-empty-show-fail"
fi
# 3 nomal repo show
perl legit.pl add a
testout=$(perl legit.pl commit -m "message0")
testout3=$(perl legit.pl show 0:a 2>&1)
ans3=$(cat a)
# 3 nomal repo show
if [ "$ans3" = "$testout3" ];
then
  echo "3-nomal-show-pass"
else
  echo "3-nomal-show-fail"
fi

# 4 wrong command
testout4=$(perl legit.pl show wrongcommand 2>&1)
ans4="usage: legit.pl show <commit>:<filename>"
# 4 wrong command
if [ "$ans4" = "$testout4" ];
then
  echo "4-wrong-command-show-pass"
else
  echo "4-wrong-command-show-fail"
fi

# 5 file not in that commit
testout5=$(perl legit.pl show 0:b 2>&1)
ans5="legit.pl: error: 'b' not found in commit 0"
# 5 file not in that commit
if [ "$ans5" = "$testout5" ];
then
  echo "5-file-not-in-that-commit-show-pass"
else
  echo "5-file-not-in-that-commit-show-fail"
fi
# 6 unknow commit
testout6=$(perl legit.pl show 1:a 2>&1)
ans6="legit.pl: error: unknown commit '1'"
# 6 unknow commit
if [ "$ans6" = "$testout6" ];
then
  echo "6-unknow-commit-show-pass"
else
  echo "6-unknow-commit-show-fail"
fi

# 7 die not found in index
testout7=$(perl legit.pl show :b 2>&1)
ans7="legit.pl: error: 'b' not found in index"
# 7 die not found in index
if [ "$ans7" = "$testout7" ];
then
  echo "7-not-in-show-pass"
else
  echo "7-not-in-show-fail"
fi

# 8 index show
echo "b"> b
perl legit.pl add b
testout8=$(perl legit.pl show :b 2>&1)
ans8=$(cat b)
if [ "$ans8" = "$testout8" ];
then
  echo "8-index-show-pass"
else
  echo "8-index-show-fail"
fi


echo ""
rm -rf .legit
rm a b
