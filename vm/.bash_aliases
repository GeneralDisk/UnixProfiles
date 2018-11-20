#Bash aliases

CURPROJ='bootcamp'
CURPROJ_DIR='tools/tests/core/torture'

alias proj='cd ~/work/purity/$CURPROJ_DIR'
alias pure='cd ~/work/purity'
alias plib='cd ~/work/purity/tools/pure/lib'
alias pureb='cd ~/work/bld_linux/purity'
alias boot='cd ~/work/purity/kernel/bootcamp'
alias log='cd /mnt/cluster_nfs/'

alias run='pb run runtests $CURPROJ'
alias runc='pb run --clean runtests $CURPROJ'

alias virtual_install='source ~/fixtestenv/bin/activate'
alias virtual_uninstall='deactivate'
