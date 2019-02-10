1XA3 Project01

The implemented features in the project are Script Input (5.1), Merge Log (5.4), TODO Log (5.2) and Find last working file (5.7).

(TODO) The custom freature developed upates the repo specified on a remote server. It logs into the remote remote server using SSH, for the first time the user has to input the details, password; username; etc, and then the script creates public private key pair and uses then to login via public key encryption. It the finds all the local repositories and prompts the user to choose wich one they want to update. All the data, repo location; username and adresss, are stored in an encrypted file that only the user can acess via a password.

For this project, the only file that the user should interact with is the main.sh file. They will be prompted for input to choose what feature use/run. multiple features/scripts can be executed in the same session. Users can chose to end the sesssion after each feature ran.

Each feature is in its own script.
