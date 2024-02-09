# Automate GitHub Repository Initialization with Bash

https://github.com/cosmicwanderer7/github-script/assets/65147258/b2f25967-cf33-4d5a-ab1e-5a885a40004a

This Bash script automates the process of creating a new GitHub repository, initializing it with a README file, and pushing the initial commit to the remote repository. The script prompts the user for a repository name and utilizes the GitHub API to create a new public repository.

## Prerequisites

Before using this script, make sure you have the following:

- GitHub account
- GitHub username
- [GitHub personal access token with repo scope](https://docs.github.com/en/enterprise-server@3.9/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

## Instructions (mkgit.sh)

1.  Clone the repository to your local machine:

    ```bash
    git clone https://github.com/your-username/bash-github-repo-creator.git
    ```

3. Navigate to the cloned directory:

    ```bash
    cd bash-github-repo-creator
    ```

4. Make the script executable:
 
   ```bash
   chmod +x mkgit.bash
   ```
   
5. Execute the script

   ```bash
   ./github_repo_creator.sh [-d] [-i] [-l] [-h]
   ```
   ###Flags

   -d: Delete the configuration file and exit.
   -i: Initialize a Git repository in the current directory.
   -l: Prompt for license selection.
   -h: Display the help message.

   Runing script without any flags makes new repo without licence at $HOME/Documents/Projects

7. The first time you use the script, it will prompt you to enter your GitHub credentials. These credentials will be saved in a configuration file for further use.

8. To run the script globally.

   copy the script to ```/usr/local/bin```

9. The script will create a new directory with the given repository name, initialize a Git repository, create an initial commit with a README file, and push it to the newly created GitHub repository.


## Instructions (mkgit-gh.sh)

1. Set Github Personal Access Token when prompted and the script will handle everything on its own.

   ```
   Replace your token at $token only if not prompted
   ```

Feel free to fork this repository, make any changes, and suggest improvements. Your contributions are welcome!
