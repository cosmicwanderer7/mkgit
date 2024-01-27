# GitHub Repository Initialization Script

https://github.com/cosmicwanderer7/github-script/assets/65147258/b2f25967-cf33-4d5a-ab1e-5a885a40004a

This Bash script automates the process of creating a new GitHub repository, initializing it with a README file, and pushing the initial commit to the remote repository. The script prompts the user for a repository name and utilizes the GitHub API to create a new public repository.

## Prerequisites

Before using this script, make sure you have the following:

- GitHub account
- GitHub username
- GitHub personal access token with repo scope

## Instructions

1. Set your GitHub username and personal access token:

    ```bash
    # GitHub username 
    GITHUB_USERNAME="YourGitHubUsername"

    # GitHub personal access token
    GITHUB_TOKEN="YourGitHubPersonalAccessToken"
    ```

2. Navigate to the desired directory where you want to create the new repository:

    ```bash
    cd /path/to/your/Documents
    ```

3. Run the script:

    ```bash
    ./script_name.sh
    ```

4. Enter the desired repository name when prompted.

5. The script will create a new directory with the given repository name, initialize a Git repository, create an initial commit with a README file, and push it to the newly created GitHub repository.

## Script Explanation

- `git init -b main`: Initializes a new Git repository with the main branch.

- `curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" https://api.github.com/user/repos -d '{"name":"'"$REPO_NAME"'", "private": false}'`: Uses the GitHub API to create a new public repository with the specified name.

- `git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"`: Sets the remote repository URL.

- `git branch -M main`: Renames the default branch to main.

- `git push -u origin main`: Pushes the initial commit to the remote repository.

- `code .`: Opens the repository in Visual Studio Code (you may need to have it installed).

Feel free to fork this repository, make any changes, and suggest improvements. Your contributions are welcome!
