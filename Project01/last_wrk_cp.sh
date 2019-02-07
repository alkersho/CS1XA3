#!/bin/bash
#python -m py_compile script.py
#stack ghc --verbosity error script.hs
cd ../
read -p "Please enter the name of the file you want to fix.
" file
case $file in
  *.py )
    errors=$(python -m py_compile "$file");;
  *.hs )
    errors=$(stack ghc --verbosity error "$file");;
esac

if [[ -n $errors ]]; then
  echo "The file compiles successfuly!"
  exit
fi
git_log=$(git log --oneline | cut -d' ' -f1)
for hash in $git_log ; do
  git checkout $hash -- $file
  case $file in
    *.py )
      errors=$(python -m py_compile "$file");;
    *.hs )
      errors=$(stack ghc --verbosity error "$file");;
  esac

  if [[ -n $errors ]]; then
    echo "A working version has been found at $hash!"
    git commit -m "reverted $file to latest working state from hash: $hash"
    exit
  fi
done
