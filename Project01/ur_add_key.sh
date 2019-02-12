#!/bin/bash
if [[ $# -eq 0 ]]; then
  echo "no arguments, failed"
  exit
fi
if [[ !( -d "$HOME/.ssh")]]; then
  mkdir .ssh
fi
echo "$1" >> "$HOME/.ssh/authorized_keys"
