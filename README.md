# Automate GitHub Repository Initialization with Bash

https://github.com/cosmicwanderer7/github-script/assets/65147258/25a6293a-f326-484e-afc9-fa08b8016ba1

This Bash script automates the process of creating a new GitHub repository, initializing it with a README file, and pushing the initial commit to the remote repository. The script prompts the user for a repository name and utilizes the GitHub API to create a new public repository.

## Prerequisites

Before using this script, make sure you have the following:

- GitHub account
- GitHub username
- [GitHub personal access token with repo scope](https://docs.github.com/en/enterprise-server@3.9/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

## Installation Instructions (mkgit.bash)

### Archlinux/Manjaro

   ```yay -S mkgit```

1.  Clone the repository to your local machine:

    ```bash
    git clone https://github.com/your-username/bash-github-repo-creator.git
    ```

2.  Navigate to the cloned directory:

    ```bash
    cd bash-github-repo-creator
    ```

3.  Make the script executable:

    ```bash
    chmod +x mkgit.bash
    ```

4.  Execute the script

    ```bash
    ./mkgit.bash [-d] [-i] [-l] [-h]
    ```

    ###Flags

    -d: Delete the configuration file and exit.
    -i: Initialize a Git repository in the current directory.
    -l: Prompt for license selection.
    -h: Display the help message.

    Runing script without any flags makes new repo without licence at $HOME/Documents/Projects

5.  The first time you use the script, it will prompt you to enter your GitHub credentials. These credentials will be saved in a configuration file for further use.

6.  To run the script globally.

    copy the script to `/usr/local/bin`

    you can create a alias

    ```
    alias mkgit='mkgit.bash'
    ```

7.  The script will create a new directory with the given repository name, initialize a Git repository, create an initial commit with a README file, and push it to the newly created GitHub repository.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request. Make sure to follow the contribution guidelines.

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

---
