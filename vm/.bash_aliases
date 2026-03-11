#Bash aliases

CURPROJ='ha.multipath' #'bootcamp'
CURPROJ_DIR='tools/ndu' #'tools/tests/core/torture'
PAWS_SSH_KEY='/home/mkali/work/purity/paws/scripts/common_dev_key.pem'
SCRIPT_HOME='/home/mkali/work/scripts'

alias proj='cd ~/work/purity/$CURPROJ_DIR'
alias rt='python3.10 -m pytest -v --disable-warnings ~/work/purity/$CURPROJ_DIR'
alias pure='cd ~/work/purity'
alias ws='cd ~/work/workspace'
alias atom='cd /home/mkali/work/cdu-atom-scripts;'
alias purest='cd ~/work/purest'
#git submodule update' removed while working on cdu-common stuff
alias pdoc='cd ~/work/purity/cpp_docs/source'
alias plib='cd ~/work/purity/tools/pure/lib'
alias pureb='cd ~/work/bld_linux/purity'
alias boot='cd ~/work/purity/kernel/bootcamp'
alias log='cd /mnt/cluster_nfs/'
alias tri='cd ~/work/triage/'
alias tlog_ini='sudo mount -t nfs -o tcp data.dogfood-newspaper.dev.purestorage.com:/tlogs /home/mkali/work/logs/tlogs; sudo mount -t nfs -o tcp data.dogfood-lambchop.dev.purestorage.com:/df-ci-logs /home/mkali/work/logs/archive'
alias cur_pytest='pytest --testbed vm-mkali tests/core/functional/ndu/test_ndu_oxygen.py --reset --test-only --ac-config /home/mkali/work/purity/tools/tests/core/torture/altered_carbon_configs/platinum_xenon_dnvr.cfg -v'
alias build_ppkg='phtest post --extra_params="BUILD_TARGET=ppkg" p_flow'
#alias build_ppkg='python2 /home/mkali/work/phtest/phtest/phtest post --extra_params="BUILD_TARGET=ppkg" p_flow'
alias build_iso='phtest post --extra_params="BUILD_TARGET=iso" p_flow'
#alias build_iso='python2 /home/mkali/work/phtest/phtest/phtest post --extra_params="BUILD_TARGET=iso" p_flow'
alias pht='python2 /home/mkali/work/phtest/phtest/phtest'
alias pf='pfind'
alias ff='vi ~/work/purity/feature_flags_config.yaml'

#alias print_freq_diags='python /home/mkali/work/purity/tools/pure/alert/tools/print_freq_diags.py'
alias print_freq_diags='/home/mkali/work/pure_support/pure_tools/pure_support/pure_support/underground/print_freq_diags.py'
# git aliases
alias gfiles='git diff-tree --no-commit-id --name-only -r'
alias gfh='git log -p --follow'

# Script home aliases
alias check_commits='python3 /home/mkali/work/scripts/python/check_commits.py'
alias decode_key='python3 $SCRIPT_HOME/decode_key.py'
alias decode_ps='python3 $SCRIPT_HOME/decode_portal_state.py'
alias proj_sync="bash $SCRIPT_HOME/project_scp.sh"
alias get_ppkg_wget='python3 $SCRIPT_HOME/get_wget_cmd.py'

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
alias orch_update="python3.6 -m pip install -U orchestrator-client"
alias orch='python3.6 /home/mkali/.virtualenvs/orchestrator/bin/orchestrator'

# Octillion Aliases
alias set_octillion_virtual_source="workon octillion"
alias oct_repo="cd ~/work/fa_smart_signals"
alias oct_manual="cd ~/work/oct_manual_signals/"
alias oct_jup_edit_cfg="vi /home/mkali/.jupyter/jupyter_notebook_config.py"
alias oct_jup_start_server="jupyter notebook"

# SSH alias for paws aws instances.  Use like ssh cmd
alias sshp='ssh -i $PAWS_SSH_KEY'
