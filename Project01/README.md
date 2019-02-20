# 1XA3 Project01

The implemented features in the project are:
* Script Input (5.1)
* Merge Log (5.4)
* TODO Log (5.2)
* Find last working file (5.7).
* Custom Feature (Update git repo on remote server)

### TODO
 - [ ] Create a log directory where all log files are stored
 - [ ] <sub>maybe</sub> Put scripts related to different features inside different directories for organisation purposes

## Interacting with the Project
For this project, the only file that the user should interact with is the `main.sh` file. They will be prompted for input to choose what feature to use/run. Multiple features/scripts can be executed in the same session. Users can chose to end the sesssion after each feature ran.

Example output from main.sh:

```
Would you like to use another feature?
  1: Merge Log
  2: TODO Log
  3: Last Working File
  4: Update Remote Repo
  0: Exit
```

## Merge Log
#### Input
None
#### Ouput
File: merge.log
#### Description
This script looks through all the git commit logs and finds all commits with the work 'merge' mentioned in them. Then it copies all the corresponding commit hashes and copies them into the file merge.log. 

## TODO  Log
#### Input
None
#### Ouput
File: todo.log
#### Description
Looks though all the files in the repo for the word `TODO` and copies the line where it is mentioned inside todo.log file.

## Find Last Working File
#### Input
File name (python or Haskell file)
#### Output
None
#### Description


## Custom Feature (Update git repo on remote server)
#### Input
* Host name
* git repo
#### Output
None
#### Description
The custom freature developed upates the repo specified on a remote server. It logs into the remote remote server using SSH, for the first time the user has to input the details, password; username; etc, and then the script creates public private key pair and uses then to login via public key encryption. It then finds all the local repositories and prompts the user to choose wich one they want to update. All the data, repo location; username and adresss, are stored in an encrypted file that only the user can acess via a password.
