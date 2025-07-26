#/bin/bash

# Set Variables
pkgList=/path/to/List
# Should this read from a file
pkgName=(
vlc	
)

# Clear Approve PKG List
> $pkgList

# Setup Array Loop

dnf install --assumeno $pkgName | grep -E 'x86_64|noarch' | grep -v rhel-9 | grep -v "Operation aborted." | cut -d" " -f2 >> $pkgList