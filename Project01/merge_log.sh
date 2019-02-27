#!/bin/bash
#get all git logs in one line, then filter where 'merge' is mentioned and extract the hash from the output from each line
git_log=$(git log --oneline | grep -i "merge" | cut -d' ' -f1)
echo "$git_log" > merge.log
