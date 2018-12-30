#!/bin/sh
#test for rm --cached
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

## 2 nomal  rm --cached
echo "a1" > a
perl legit.pl add a
testout=$(perl legit.pl commit -m "message0")
perl legit.pl rm --cached a
## 2 nomal   rm --cached
if (test -e a)
!(grep "a" '.legit/index')
then
  echo "2-nomal-rm-pass"
else
  echo "2-nomal-rm-fail"
fi

## 3 has been rmed already
testout2=$(perl legit.pl rm --cached a 2>&1)
ans2="legit.pl: error: 'a' is not in the legit repository"
## 3 has been rmed already
if [ "$ans2" = "$testout2" ]; then
  echo "3-rm-already-rm-pass"
else
  echo "3-rm-already-rm-fail"
fi


## 4 only on working dir
testout=$(perl legit.pl commit -m "message1")
echo "b1" > b
testout4=$(perl legit.pl rm --cached b 2>&1)
ans4="legit.pl: error: 'b' is not in the legit repository"
## 4 only on working dir
if [ "$ans4" = "$testout4" ]; then
  echo "4-only-working-dir-rm-pass"
else
  echo "4-only-working-dir-rm-fail"
fi


## 5 rm a file new add to index but now commit
perl legit.pl add b
testout5=$(perl legit.pl rm --cached b 2>&1)
## 5 rm a file new add to index but now commit
if (test -e b)
!(grep "b" '.legit/index')
then
  echo "5-new-add-index-rm-cached-pass"
else
  echo "5-new-add-index-rm-cached-fail"
fi


## 6 rm a file changed --cached

perl legit.pl add b
testout=$(perl legit.pl commit -m "message2")
echo "b2" >> b
testout6=$(perl legit.pl rm --cached b 2>&1)

## 6 rm a file changed --cached
if (test -e b)
!(grep "b" '.legit/index')
then
  echo "6-changed-file-rm-cached-pass"
else
  echo "6-changed-file-rm-cached-fail"
fi

## 7 rm a file changed add to staged

perl legit.pl add b
testout7=$(perl legit.pl rm --cached b 2>&1)

## 7 rm a file changed add to staged
if (test -e b)
!(grep "b" '.legit/index')
then
  echo "7-changed-file-staged-rm-cached-pass"
else
  echo "7-changed-file-staged-rm-cached-fail"
fi

## 8 rm a file added to staged then change aging

perl legit.pl add b
echo "b3" >> b
testout8=$(perl legit.pl rm --cached b 2>&1)
ans8="legit.pl: error: 'b' in index is different to both working file and repository"
## 8 rm a file added to staged then change aging

if [ "$ans8" = "$testout8" ]; then
  echo "8-working-staged-repo-alldif-rm-cached-pass"
else
  echo "8-working-staged-repo-alldif-rm-cached-fail"
fi

## 9 rm after unix rm

testout=$(perl legit.pl commit -m "message8")
rm b
testout9=$(perl legit.pl rm --cached b 2>&1)
## 9 rm after unix rm
if !(test -e b)
!(grep "b" '.legit/index')
then
  echo "9-rm-after-unix-rm-f-pass"
else
  echo "9-rm-after-unix-rm-f-fail"
fi

echo ""
rm -rf .legit
rm a
