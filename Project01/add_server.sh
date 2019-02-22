#!/bin/bash

file_p=$1
read -p "Server address:" address
read -p "Login username:" usr_nm
if [[ !(-f "repo_data") ]]; then
  openssl aes-256-cbc -d -salt -in repo_data.enc -out repo_data -k "$file_p"
fi
echo "$usr_nm@$address;" >> repo_data
openssl aes-256-cbc -e -salt -in repo_data -out repo_data.enc -k "$file_p"
rm repo_data
if [[ !( -d "$HOME/.ssh" )]]; then
  mkdir "$HOME/.ssh"
fi
ssh-keygen -b 2048 -t rsa -f "$HOME/.ssh/$address auto" -N "" -q
pub_key=$(cat "$HOME/.ssh/$address auto.pub")
echo "Adding public key to remote server to automate login..."
ssh $usr_nm@$address -o PubkeyAuthentication=no "bash -s" < ./ur_add_key.sh $pub_key
