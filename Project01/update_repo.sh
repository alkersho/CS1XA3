#!/bin/bash

#first time running script, hence repo_data.enc doesn't exist
if [[ !(-f 'repo_data.enc') ]]; then
  echo " Choose a password for encrypted file to store server data, no passwords saved(remember this as you will need it everytime you run this script):"
  #read entered password
  read -s file_p
  #create empty file
  touch repo_data
  #execute script to add data to the file
  bash ./add_server.sh $file_p
else
  #server data file already exists and encrypted
  echo "Enter encrypted file password:"
  read -s file_p
fi

#try read encrypted file using given password
cont=$(openssl aes-256-cbc -d -salt -in repo_data.enc -k "$file_p" | tr -d '[:space:]')
#checks if decryption succeded or not
while [[ -z $cont ]]; do
  echo "Wrong password, please try again."
  read -s file_p
  cont=$(openssl aes-256-cbc -d -salt -in repo_data.enc -k "$file_p" | tr -d '[:space:]')
done
#put data into array seperated by ';'
IFS=';' read -r -a servers <<< $cont
len=${#servers[@]}
#lists all server option and gives the option to add a new server to the list
echo "Please choose a server to connect to"
echo "0: Add a new server"
for (( i = 0; i < $len; i++ )); do
  ((i+=1))
  echo "$i: ${servers[i]}"
done
read choice

#if choice is valid and is not '0' skip loop and execute script on desired server
#if choice is zero execute 'add_server.sh' to add a server to the encrypted file
while [[ $((choice)) != $choice ]] || [[ ! $choice -lt $len ]] || [[ $choice  == 0]]; do
  if [[ $choice != 0 ]]; then
    echo "Invalid choice"
  fi
  if [[ $choice == 0 ]]; then
    bash ./add_server.sh $file_p
  fi
  #update cont variable and servers array to reflect addition to the server list
  cont=$(openssl aes-256-cbc -d -salt -in repo_data.enc -k "$file_p" | tr -d '[:space:]')
  IFS=';' read -r -a servers <<< $cont
  len=${#servers[@]}
  #lists all server option and gives the option to add a new server to the list
  echo "Please choose a server to connect to."
  echo "0: Add a new server"
  for (( i = 0; i < $len; i++ )); do
    j=$((i+1))
    echo "$j: ${servers[i]}"
  done
  read choice
done

#send a script to the desired server to be executed to update the repo
scp -o PubkeyAuthentication=yes ur_remote.sh "${servers[$choice]}:/home/$usr_nm/ur_remote.sh"
#execute the script remotely
ssh "${servers[$choice]}" -o PubkeyAuthentication=yes "bash ./ur_remote.sh"
