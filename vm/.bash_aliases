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
alias tlog_ini='sudo mount -t nfs -o tcp data.dogfood-newspaper.dev.purestorage.com:/tlogs /home/mkali/work/logs/tlogs; sudo mount -t nfs -o tcp data.dogfood-lambchop.dev.purestorage.com:/df-ci-logs /home/mkali/work/logs/archive'
#alias print_freq_diags='python /home/mkali/work/purity/tools/pure/alert/tools/print_freq_diags.py'
alias print_freq_diags='/home/mkali/work/pure_support/pure_tools/pure_support/pure_support/underground/print_freq_diags.py'
# git aliases
alias gfiles='git diff-tree --no-commit-id --name-only -r'
alias gfh='git log -p --follow'

# Script home aliases
alias check_commits='python3 /home/mkali/work/scripts/python/check_commits.py'

# to rebuild kernal repro, nav to purity/linux-kernel/ and type 'make release-tree'
alias kern='cd ~/work/bld_linux/linux-2.6.git'

alias blib='cd ~/work/bld_linux/purity/lib'

#alias run='pb run runtests $CURPROJ'
#alias runc='pb run --clean runtests $CURPROJ'

alias virtual_install='source ~/fixtestenv/bin/activate'
alias virtual_install_new='source /home/mkali/work/purity/tools/pure/bin/setup_fixtest'
alias virtual_uninstall='deactivate'

# PBS aliases.  Checkout https://wiki.purestorage.com/display/psw/Benchmark+System#BenchmarkSystem-Reservations if there are issues
alias helpprint_pbs='printf "Pure Benchmark setup.  You must be in the automation dir for this to work. Use pbs alias for bs.py.\nFor help, checkout https://wiki.purestorage.com/display/psw/Benchmark+System#BenchmarkSystem-Reservations\n"'
alias set_perf_virtual_source='source /home/mkali/work/pbs/performance/automation/venv/bin/activate; cd /home/mkali/work/pbs/performance/automation/; helpprint_pbs'
alias pbs='python /home/mkali/work/pbs/performance/automation/bs.py'

# Depreciated legacy orchestrator diz
# alias set_orch_virtural_source="source ~/venv/bin/activate"
# alias orch='PYTHONPATH=${PURE_TOOLS}/.. ${PURE_TOOLS}/ci/mockingbird/webapps/orchestrator/cli/orchestrator.py'
#alias set_orch_virtural_source="source ~/work/orchestratorenv/bin/activate"
alias set_orch_virtual_source="workon orchestrator"
alias orch_update="pip install -U orchestrator-client"
alias orch='orchestrator'

# SSH alias for paws aws instances.  Use like ssh cmd
alias sshp='ssh -i $PAWS_SSH_KEY'
