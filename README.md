# UnixProfiles
Repo for all my unix configuration files, useful for VMs

#### Mac and VM setup tools ####

One of the primary purposes of this repo is to make setup on a new computer or vm simple.  To
facilitate this, the "unpack_" scripts exist to deploy all bash/vimrc (and other basic cfg files)
files to the new machine.  Their basic usage is to specify a target directory, which should be your
default bashrc root home, otherwise it just shoves the files one level up (which is why it's good
practice to put your UnixProfiles repo in the root home directory).

Along with these files, the script will also deploy a "pack_" script, which can be used to update
the repository with any local changes that are made.

Generally, each sub-dir in this repo contains platform-specific config files.  However, the exception
is the 'shared' directory, which contains elements used by multiple platform.  Use this judiciously.

#### Misc Files and Scripts ####

Along with platform-specific configuration files, there are also a set of miscellaneous scripts that
I thought would be nice to preserve.  Such as the "power_shelves.sh" script.  These should go in a
"misc" subdir.
