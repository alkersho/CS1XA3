#!/bin/bash
read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input

while [[ true ]]; do
  if [[ $input -eq "1" ]]; then
    echo "execute 'megre_log.sh'"
    bash ./merge_log.sh
    read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
  elif [[ $input -eq "2" ]]; then
    echo "Executing 'todo_log.sh'"
    bash ./todo_log.sh
    read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
  elif [[ $input -eq "3" ]]; then
    echo "Executing 'last_wrk_cp.sh'"
    bash ./last_wrk_cp.sh
    read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
  elif [[ $input -eq "4" ]]; then
    echo "Executing 'last_wrk_cp.sh'"
    bash ./update_repo.sh
    read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
  elif [[ $input -eq "0" ]]; then
    echo "Have a good day!"
    exit
  else
    read -p "Unrecognised option. Please choose a feature to execute(enter the corresponding number):
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
  fi
done
