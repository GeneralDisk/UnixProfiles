#Bash aliases

CURPROJ='ha.multipath' #'bootcamp'
CURPROJ_DIR='platform/ha' #'tools/tests/core/torture'
PAWS_SSH_KEY='/home/mkali/work/purity/paws/scripts/common_dev_key.pem'

alias proj='cd ~/work/purity/$CURPROJ_DIR'
alias pure='cd ~/work/purity'
alias pdoc='cd ~/work/purity/cpp_docs/source'
alias plib='cd ~/work/purity/tools/pure/lib'
alias pureb='cd ~/work/bld_linux/purity'
alias boot='cd ~/work/purity/kernel/bootcamp'
alias log='cd /mnt/cluster_nfs/'
alias tri='cd ~/work/triage/'
alias print_freq_diags='python /home/mkali/work/purity/tools/pure/alert/tools/print_freq_diags.py'

# git aliases
alias gfiles='git diff-tree --no-commit-id --name-only -r'

# to rebuild kernal repro, nav to purity/linux-kernel/ and type 'make release-tree'
alias kern='cd ~/work/bld_linux/linux-2.6.git'

alias blib='cd ~/work/bld_linux/purity/lib'

#alias run='pb run runtests $CURPROJ'
#alias runc='pb run --clean runtests $CURPROJ'

alias virtual_install='source ~/fixtestenv/bin/activate'
alias virtual_install_new='source /home/mkali/work/purity/tools/pure/bin/setup_fixtest'
alias virtual_uninstall='deactivate'

# Depreciated legacy orchestrator diz
# alias set_orch_virtural_source="source ~/venv/bin/activate"
# alias orch='PYTHONPATH=${PURE_TOOLS}/.. ${PURE_TOOLS}/ci/mockingbird/webapps/orchestrator/cli/orchestrator.py'
alias set_orch_virtural_source="source ~/work/orchestratorenv/bin/activate"
alias orch='orchestrator'

# SSH alias for paws aws instances.  Use like ssh cmd
alias sshp='ssh -i $PAWS_SSH_KEY'
