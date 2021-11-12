# Kurt's System Configuration
This project is a repository for [my](https://github.com/kurt-stolle) personal system configuration files.
This enables me to quickly load my preferences (like Vim and Tmux keybinds) into a new environment.

## Installation
### Linux
Run the `setup.sh` script.
```
bash $(curl https://kurt-stolle.github.io/preferences/setup.sh)
```
This downloads all preferences over HTTP and replaces the relevant target, no Git required.

### Windows
No Windows configuration files are currently in place.

## Structure
Directories are named after programs.
If a configuration is OS-specific, a sub-folder that describes the environment contains the relevant configuration files.
