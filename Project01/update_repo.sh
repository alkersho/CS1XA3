#!/bin/bash

#first time running script
if [[ !(-f 'repo_data.enc') ]]; then
  echo "Password for encrypted file(remember this as you will need it everytime you run this script):"
  read -s file_p
  read -p "Server address:" address
  read -p "Login username:" usr_nm
  if [[ !( -d "$HOME/.ssh" )]]; then
    mkdir "$HOME/.ssh"
  fi
  echo $address > repo_data
  echo $usr_nm >> repo_data
  openssl aes-256-cbc -e -salt -in repo_data -out repo_data.enc -k "$file_p"
  rm repo_data
  ssh-keygen -b 2048 -t rsa -f "$HOME/.ssh/$address auto" -N "" -q
  pub_key=$(cat "$HOME/.ssh/$address auto.pub")
  ssh $usr_nm@$address -o PubkeyAuthentication=no "bash -s" < ./ur_add_key.sh $pub_key
else
  echo "Enter encrypted file password:"
  read -s file_p
  cont=$(openssl aes-256-cbc -d -salt -in repo_data.enc -k "$file_p")
  while [[ -z $cont ]]; do
    echo "Wrong password, please try again."
    read -s file_p
    cont=$(openssl aes-256-cbc -d -salt -in repo_data.enc -k "$file_p")
  done
  address=$(echo $cont | cut -d' ' -f1)
  usr_nm=$(echo $cont | cut -d' ' -f2)
fi
scp ur_remote.sh "$usr_nm@$address:/home/$usr_nm/ur_remote.sh"
ssh "$usr_nm@$address" -o PubkeyAuthentication=yes "bash ./ur_remote.sh"
