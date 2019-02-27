#!/bin/bash
read -p "Choose a feature to execute
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input

#loops infinitely untll user terminates the program by entering "0"
while [[ true ]]; do
  #executes a sctipt based on the option entered by the user
  case $input in
    "1" )
      echo "executing 'megre_log.sh'"
      bash ./merge_log.sh
      clear
      echo "Executed 'merge_log.sh' successfuly!"
      read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
      ;;
    "2" )
      echo "execute 'todo_log.sh'"
      bash ./todo_log.sh
      clear
      echo "Executed 'todo_log.sh' successfuly!"
      read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
      ;;
    "3" )
      echo "execute 'last_wrk_cp.sh'"
      bash ./last_wrk_cp.sh
      clear
      echo "Executed 'last_wrk_cp.sh' successfuly!"
      read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
      ;;
    "4" )
      echo "execute 'update_repo.sh'"
      bash ./update_repo.sh
      clear
      echo "Executed 'update_repo.sh' successfuly!"
      read -p "Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
      ;;
    "0" )
    echo "Have a great day!"
    exit
      ;;
    * )
      read -p "Please choose a valid option:
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
" input
      ;;
  esac
done
