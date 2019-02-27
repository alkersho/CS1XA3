#!/bin/bash

#adds public key to the server

#this should never happen
if [[ $# -eq 0 ]]; then
  echo "no arguments, failed(This should never happen!)"
  exit
fi
#create .ssh dir if it doesn't exist
if [[ !( -d "$HOME/.ssh")]]; then
  mkdir .ssh
fi
#copy public key into authorized_keys file to automate login
echo "$1" >> "$HOME/.ssh/authorized_keys"
