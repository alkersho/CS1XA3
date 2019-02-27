#!/bin/bash
cd ../
read -p "Please enter the name of the file you want to fix: " file

#makes sure that the file is actually a python or a haskell file
while [[ !($file == "*.py" || $file == "*.hs") ]]; do
  read -p "Please enter a valid file type, *.py or *.hs: " file
done

#check if there are any compiler errors at current version
case $file in
  *.py )
    errors=$((python3 -m py_compile "$file") 2> &1);;
  *.hs )
    errors=$((stack ghc --verbosity error "$file") 2> &1);;
esac

#if the file compiles successfuly then say so and quit
if [[ -n $errors ]]; then
  #finds all .pyc files and deletes all that are not tracked by git as to not create any new files, not sure how to not create them in the first place :/
  pyc_files=$(find . -name *.pyc)
  for file in $pyc_files; do
    git_file_log=$(git ls-files "$file")

    if [[ -n $git_file_log ]]; then
      rm $file
    fi
  done

  echo "The file compiles successfuly!"
  exit
fi

#checks for compiler error for older versions
git_log=$(git log --oneline | cut -d' ' -f1)
for hash in $git_log ; do
  git checkout $hash -- $file
  case $file in
    *.py )
      errors=$((python3 -m py_compile "$file") 2> &1);;
    *.hs )
      errors=$((stack ghc --verbosity error "$file") 2> &1);;
  esac

  if [[ -n $errors ]]; then
    #no compiler errors found
    echo "A working version has been found at $hash!"

    #finds all .pyc files and deletes all that are not tracked by git as to not create any new files, not sure how to not create them in the first place :/
    pyc_files=$(find . -name *.pyc)
    for file in $pyc_files; do
      git_file_log=$(git ls-files "$file")
      if [[ -n $git_file_log ]]; then
        rm $file
      fi
    done
    #commit older version and exit
    git commit -m "reverted $file to latest working state from hash: $hash"
    exit
  fi
done

#no working version found, get current branch and revert all changes
branch=$(git branch | grep \* | cut -d' ' -f2)
git checkout "$branch" -- "$file"
echo "No working version found :("
