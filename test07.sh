#!/bin/sh
#test for rm --force
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

## 2 nomal  rm --force
echo "a1" > a
perl legit.pl add a
testout=$(perl legit.pl commit -m "message0")
perl legit.pl rm --force a
## 2 nomal   rm --force
if !(test -e a)
!(grep "a" '.legit/index')
then
  echo "2-nomal-rm-pass"
else
  echo "2-nomal-rm-fail"
fi

## 3 has been rmed already
testout2=$(perl legit.pl rm --force a 2>&1)
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
testout4=$(perl legit.pl rm --force b 2>&1)
ans4="legit.pl: error: 'b' is not in the legit repository"
## 4 only on working dir
if [ "$ans4" = "$testout4" ]; then
  echo "4-only-working-dir-rm-pass"
else
  echo "4-only-working-dir-rm-fail"
fi


## 5 rm a file new add to index but now commit
perl legit.pl add b
testout5=$(perl legit.pl rm --force b 2>&1)
## 5 rm a file new add to index but now commit
if !(test -e b)
!(grep "b" '.legit/index')
then
  echo "5-new-add-index-rm-f-pass"
else
  echo "5-new-add-index-rm-f-fail"
fi


## 6 rm a file changed --force
echo "b1" > b
perl legit.pl add b
testout=$(perl legit.pl commit -m "message2")
echo "b2" >> b
testout6=$(perl legit.pl rm --force b 2>&1)
testout=$(perl legit.pl commit -m "message3")
## 6 rm a file changed --force
if !(test -e b)
!(grep "b" '.legit/index')
then
  echo "6-changed-file-rm-f-pass"
else
  echo "6-changed-file-rm-f-fail"
fi

## 7 rm a file changed add to staged
echo "b1" > b
perl legit.pl add b
testout=$(perl legit.pl commit -m "message4")
echo "b2" >> b
perl legit.pl add b
testout7=$(perl legit.pl rm --force b 2>&1)
testout=$(perl legit.pl commit -m "message5")
## 7 rm a file changed add to staged
if !(test -e b)
!(grep "b" '.legit/index')
then
  echo "7-changed-file-staged-rm-f-pass"
else
  echo "7-changed-file-staged-rm-f-fail"
fi

## 8 rm a file added to staged then change aging
echo "b1" > b
perl legit.pl add b
testout=$(perl legit.pl commit -m "message6")
echo "b2" >> b
perl legit.pl add b
echo "b3" >> b
testout8=$(perl legit.pl rm --force b 2>&1)
testout=$(perl legit.pl commit -m "message7")
## 8 rm a file added to staged then change aging

if !(test -e b)
!(grep "b" '.legit/index')
then
  echo "8-working-staged-repo-alldif-rm-f-pass"
else
  echo "8-working-staged-repo-alldif-rm-f-fail"
fi

## 9 rm after unix rm
echo "new_b" > b
perl legit.pl add b
testout=$(perl legit.pl commit -m "message8")
rm b
testout9=$(perl legit.pl rm --force b 2>&1)
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
