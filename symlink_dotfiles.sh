#!/usr/bin/env bash

# mkdir with the first argument. If the directory already exists, append _
# This function is used to create backup folder
function makedir() {
    if [ -d $1 ]; then
        param="$1_"
        echo $(makedir $param)
    else
        mkdir $1
        echo $1
    fi
}

# Create backup folder. It should not have the same name as any existing one.
backupdir=$(makedir "dotfiles_backup")

# If the backup folder is used then at the end of the script, this variable
# will have been changed. Otherwise we can assume that the folder hasn't
# been used and can be safely removed.
backedup=0

# Ignore certain git files and folders
ignores=(
        .git
        .gitignore
        .gitmodules
)


# Do stuff to each file starting with '.' in ~/dotfiles/
for file in .[!.]*; do
    echo "Found $file ..."

    # Skip if file is in ignore list
    skip=0
    for ig in ${ignores[*]}; do
        if [ "$ig" == "$file" ]; then
            skip=1
            echo "Ignored $file"
            break
        fi
    done
    if [ $skip == 1 ]; then
        continue
    fi

    # If dot file already exists in ~
    if [ -e ~/$file ]; then
        # TODO: sometimes the existing dot file is actually a symlink that
        # points to another dot file. This script may have broken such
        # symlinks by moving the target dot file. If that's the case then
        # this IF will return false, and you'll have to manually
        # create your symlink again when you want to restore your settings.
        # I've yet to find a solution for this but hopefully someday I will.

        # Make sure the script does not remove the backup file, now that it is
        # actually used
        backedup=1

        # Move file into backup folder
        mv ~/$file ~/$backupdir/$file

        echo "Backed up ~/$file to ~/$backupdir/$file"

    fi

    # Create symlink for files inside ~/dotfiles/
    rm -rf ~/$file # Remove any remaining broken symlink
    ln -s ./$file ~/$file
    echo "Symlink created: ~/$name -> ~/$file"

done

# Remove backup dir only if it hasn't been used
if [ "$backedup" -eq 0 ]; then
    rm -rf $backupdir
fi

source ~/.bashrc