#!/bin/sh
#test for add
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

# 2 add a   adding it to index and staged
perl legit.pl add a

# 2 add a   adding it to index and staged
if
test -e '.legit/staged/a'
grep -q "a" '.legit/index'
then
  echo "2-nomal-add-pass"
else
  echo "2-nomal-add-fail"
fi



# 3 add a notexist file
testout3=$( perl legit.pl add notexist  2>&1 )
ans3="legit.pl: error: can not open 'notexist'"
# 3 add a notexist file
if [ "$ans3" = "$testout3" ]; then
  echo "3-notexits-add-pass"
else
  echo "3-notexits-add-fail"
fi

# 4 add a same file
testout4=$(perl legit.pl commit -m "message0")
perl legit.pl add a

# 4 add a same file
if
test -e '.legit/staged/a'
then
  echo "4-same-add-fail"
else
  echo "4-same-add-pass"
fi

# 5 add a dif file
echo "a2" >> a
perl legit.pl add a
# 5 add a dif file

if
test -e '.legit/staged/a'
then
  echo "5-dif-add-pass"
else
  echo "5-dif-add-fail"
fi


# 6 add a already added file
perl legit.pl add a
# 6 add a already added file
testout6=$(cat .legit/staged/a)
working_a=$(cat a 2>&1)
if
test -e '.legit/staged/a'
[ "$testout6" = "$working_a" ]
then
  echo "6-already added-pass"
else
  echo "6-already added-fail"
fi


# 7 add a changed a already added file
echo "3a" >> a
perl legit.pl add a
# 7 add a changed a already added file
testout7=$(cat .legit/staged/a)
working_a=$(cat a)
if
[ "$testout7" = "$working_a" ]
then
  echo "7-changed-already-added-pass"
else
  echo "7-changed-already-added-fail"
fi

# 8 add a legit rm file
testout=$(perl legit.pl commit -m "message1")
perl legit.pl rm a
testout8=$(perl legit.pl add a 2>&1 )
ans8="legit.pl: error: can not open 'a'"
# 8 add a legit rm file
if
[ "$testout8" == "$ans8" ]
then
  echo "8-legi-rm-added-pass"
else
  echo "8-legit-rm-added-fail"
fi


# 9 add a unix rm file
testout=$(perl legit.pl commit -m "message2")
echo "a_new" > a
perl legit.pl add a
testout=$(perl legit.pl commit -m "message3")
rm a
perl legit.pl add a
# 9 add a unix rm file
if
grep -q "a" '.legit/del'
then
  echo "9-unix-rm-added-pass"
else
  echo "9-unix-rm-added-fail"
fi








echo ""
rm -rf .legit
