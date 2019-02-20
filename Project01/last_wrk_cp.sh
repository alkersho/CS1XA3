#!/bin/bash
cd ../
read -p "Please enter the name of the file you want to fix: " file

while [[ !($file == "*.py" || $file == "*.hs") ]]; do
  read -p "Please enter a valid file type, *.py or *.hs: " file
done

#check if there are any errors or no
case $file in
  *.py )
    errors=$(python3 -m py_compile "$file");;
  *.hs )
    errors=$(stack ghc --verbosity error "$file");;
esac

if [[ -n $errors ]]; then
  for file in $pyc_files; do
    git_file_log=$(git ls-files "$file")
    if [[ -n $git_file_log ]]; then
      rm $file
    fi
  done
  echo "The file compiles successfuly!"
  exit
fi

#if file doesn't work at first
git_log=$(git log --oneline | cut -d' ' -f1)
for hash in $git_log ; do
  git checkout $hash -- $file
  case $file in
    *.py )
      errors=$(python3 -m py_compile "$file");;
    *.hs )
      errors=$(stack ghc --verbosity error "$file");;
  esac

  if [[ -n $errors ]]; then
    #if there are no errors commit older version and exit script
    echo "A working version has been found at $hash!"
    pyc_files=$(find . -name *.pyc)
    for file in $pyc_files; do
      git_file_log=$(git ls-files "$file")
      if [[ -n $git_file_log ]]; then
        rm $file
      fi
    done
    git commit -m "reverted $file to latest working state from hash: $hash"
    exit
  fi
done

branch=$(git branch | grep \* | cut -d' ' -f2)
git checkout "$branch" -- "$file"
echo "No working version found :("
