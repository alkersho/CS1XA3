#!/bin/bash
echo "logged in"
mapfile -t repos < <(find . -name ".git")
len=${#repos[@]}
# echo "$len ${repos[@]}"
echo "Please choose which repo to update"
for (( i = 0; i < $len; i++ )); do
  echo "  $i: ${repos[i]}"
done
read choice
# re='^[0-9]+$'
while [[ $((choice)) != $choice ]] || [[ ! $choice -lt $len ]]; do
  echo "Invalid choice"
  echo "Please choose which repo to update"
  for (( i = 0; i < $len; i++ )); do
    echo "$i: ${repos[i]}"
  done
  read choice
done

cd "${repos[$choice]}"
git pull
# echo "FUCKING DONE"
rm "$0"
