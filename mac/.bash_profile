#~/.bash_profile

export CLICOLOR=1

[[ -s ~/.bashrc ]] && source ~/.bashrc

export PATH="/usr/local/opt/maven@3.5/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

# Source all shareed functions.
SHARED_FUNCTION_FOLDER="$HOME/UnixProfiles/shared"
source_shared_functions()
{
        if [ -d $SHARED_FUNCTION_FOLDER ];
        then
                source $SHARED_FUNCTION_FOLDER/.fun_pfind
                source $SHARED_FUNCTION_FOLDER/.fun_rlog
                source $SHARED_FUNCTION_FOLDER/.fun_tlog
        else
                echo "$SHARED_FUNCTION_FOLDER does not exist.  Please fix it in .bash_profile"
        fi
}

source_shared_functions

# Initialize ssh keys for mac
ssh_ini
