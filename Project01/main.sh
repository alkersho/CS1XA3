#!/bin/bash
read -p "Welcome to my main scirpt!
Please choose a feature to execute(enter the corresponding number):
  1:Merge Log
  2:Exit
  " input

while [[ true ]]; do
  if [[ $input -eq "1" ]]; then
    echo "execute 'megre_log.sh'"
    ./merge_log.sh
    exit
  elif [[ $input -eq "2" ]]; then
    echo "Have a good day"
    exit
  else
    read -p "Unrecognised feature. Please choose a feature to execute(enter the corresponding number):
  1:Merge Log
  2:Exit
" input
  fi
done
