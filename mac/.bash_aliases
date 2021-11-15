#bash aliases
alias ll='ls -al'
# IF ssh poblems, ssh_ini
alias ssh_ini='ssh-add -K ~/.ssh/id_rsa; ssh-add -K ~/.ssh/id_pure_root'
alias vm='reset; ssh -t vm "cd work/purity; bash --login"'

alias pure='cd ~/Work/purity'
alias python='python3'

alias uz='gunzip *.gz'

#alias plog='cd /Users/mkali/Downloads/Logs'
# alias to wrap ssh with paws authentication key call.  Use like ssh.
alias sshp='ssh -i /Users/mkali/Work/purity/paws/scripts/common_dev_key.pem'
