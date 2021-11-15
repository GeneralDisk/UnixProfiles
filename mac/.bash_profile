#~/.bash_profile

export CLICOLOR=1

[[ -s ~/.bashrc ]] && source ~/.bashrc

# Source all functions.  These are defined in bash_functions
source_functions

# Initialize ssh keys for mac
ssh_ini
