#!/bin/bash
read -p "Welcome to the main scirpt!
Please choose a feature to execute(enter the corresponding number):
  1: Merge Log
  2: TODO Log
  0: Exit
" input

while [[ true ]]; do
  if [[ $input -eq "1" ]]; then
    echo "execute 'megre_log.sh'"
    bash ./merge_log.sh
    read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  0: Exit
" input
  elif [[ $input -eq "2" ]]; then
    echo "Executing 'todo_log.sh'"
    bash ./todo_log.sh
    read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  0: Exit
" input
  elif [[ $input -eq "0" ]]; then
    echo "Have a good day!"
    exit
  else
    read -p "Unrecognised option. Please choose a feature to execute(enter the corresponding number):
  1: Merge Log
  2: TODO Log
  0: Exit
" input
  fi
done
