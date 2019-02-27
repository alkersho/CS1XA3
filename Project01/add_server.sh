#!/bin/bash

#adds the server and login info in repo_data file and creates a public key pair for automated loging in

#the password for the file was passed as the firs argument
file_p=$1
#read the server name and the username
read -p "Server address:" address
read -p "Login username:" usr_nm
#if the file doesn't exist it means that it is not encrypted
#if the encrypted file doesn't exist then the file is created by update_repo.sh at line 9 the it executes this script
if [[ !(-f "repo_data") ]]; then
  openssl aes-256-cbc -d -salt -in repo_data.enc -out repo_data -k "$file_p"
fi
#adds the data to the file in the following format and seperated by a ';' for later retrieval
echo "$usr_nm@$address;" >> repo_data
openssl aes-256-cbc -e -salt -in repo_data -out repo_data.enc -k "$file_p"
#delete unencrypted file, possibly a security threat, but I feel that encrypting it was an overkill in the first place imo.
rm repo_data

#create .ssh dir if it doesn't exist, otherwise ssh-keygen will fail
if [[ !( -d "$HOME/.ssh" )]]; then
  mkdir "$HOME/.ssh"
fi
#create public key pair and read it
ssh-keygen -b 2048 -t rsa -f "$HOME/.ssh/$address auto" -N "" -q
pub_key=$(cat "$HOME/.ssh/$address auto.pub")
echo "Adding public key to remote server to automate login..."
#send the public key to the desired server for automated loging in
ssh "$usr_nm@$address" -o PubkeyAuthentication=no "bash -s" < ./ur_add_key.sh $pub_key
