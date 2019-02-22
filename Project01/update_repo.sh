#!/bin/bash

#first time running script
if [[ !(-f 'repo_data.enc') ]]; then
  echo " Choose a password for encrypted file(remember this as you will need it everytime you run this script):"
  read -s file_p
  touch repo_data
  bash ./add_server.sh $file_p
else
  #server data file already exists and encrypted
  echo "Enter encrypted file password:"
  read -s file_p
fi

cont=$(openssl aes-256-cbc -d -salt -in repo_data.enc -k "$file_p" | tr -d '[:space:]')
while [[ -z $cont ]]; do
  echo "Wrong password, please try again."
  read -s file_p
  cont=$(openssl aes-256-cbc -d -salt -in repo_data.enc -k "$file_p")
done
IFS=';' read -r -a servers <<< $cont
len=${#servers[@]}
echo "Please choose a server to connect to"
echo "0: Add a new server"
for (( i = 0; i < $len; i++ )); do
  ((i+=1))
  echo "$i: ${servers[i]}"
done
read choice
while [[ $((choice)) != $choice ]] || [[ ! $choice -lt $len ]] || [[ $choice  == 0]]; do
  if [[ $choice != 0 ]]; then
    echo "Invalid choice"
  fi
  echo "Please choose a server to connect to."
  echo "0: Add a new server"
  for (( i = 0; i < $len; i++ )); do
    j=$((i+1))
    echo "$j: ${servers[i]}"
  done
  read choice
  if [[ $choice == 0 ]]; then
    bash ./add_server.sh $file_p
  fi
done

scp -o PubkeyAuthentication=yes ur_remote.sh "${servers[$choice]}:/home/$usr_nm/ur_remote.sh"
ssh "${servers[$choice]}" -o PubkeyAuthentication=yes "bash ./ur_remote.sh"
