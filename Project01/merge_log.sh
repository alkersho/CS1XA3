#!/bin/bash
git_log=$(git log --oneline | grep -i "merge" | cut -d' ' -f1)
echo "$git_log" >> merge.log
