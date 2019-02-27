#!/bin/bash
echo "logged in"
#get all git repos in the home directory
mapfile -t repos < <(find . -name ".git")
len=${#repos[@]}
echo "Please choose which repo to update"
#list all git repos
for (( i = 0; i < $len; i++ )); do
  dir=$(dirname "${repos[$i]}")
  echo "  $i: $dir"
done
read choice
#same trick in update_repo file to only pass loop with a valid input
while [[ $((choice)) != $choice ]] || [[ ! $choice -lt $len ]]; do
  echo "Invalid choice"
  echo "Please choose which repo to update"
  for (( i = 0; i < $len; i++ )); do
    dir=$(dirname "${repos[$i]}")
    echo "$i: $dir"
  done
  read choice
done

dir=$(dirname "${repos[$choice]}")
cd $dir
git pull
rm "$0"
