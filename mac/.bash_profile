#~/.bash_profile

export CLICOLOR=1

[[ -s ~/.bashrc ]] && source ~/.bashrc

export PATH="/usr/local/opt/maven@3.5/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

# Source all shareed functions.
SHARED_FUNCTION_FOLDER="$HOME/UnixProfiles/shared"
echo "NOTE: if $SHARED_FUNCTION_FOLDER is not the correct directory, you may have to correct it in .bash_profile"
source_shared_functions()
{
        source $SHARED_FUNCTION_FOLDER/.fun_pfind
        source $SHARED_FUNCTION_FOLDER/.fun_rlog
        source $SHARED_FUNCTION_FOLDER/.fun_tlog
}

source_shared_functions

# Initialize ssh keys for mac
ssh_ini
