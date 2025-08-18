#!/bin/bash
umask 002

# Set Colors
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
MAGENTA=$'\e[35m'
YELLOW=$'\e[33m'
BOLD=$'\e[1m'
NC=$'\e[0m' # Resets all formatting

#Get date for filename
cal=$(date +"%y%m%d")
# Set Variables
rhVersion=RHEL$(rpm -E %rhel).latest
repoLoc=/repoData/$rhVersion/
isoPath=/repoData/repoISO/$rhVersion

isoNameList=(
EXTRA_repo
"$rhVersion"_repo
)

isoPointsList=(
/epel=$repoLoc/epel \
/rpmfusion-free=$repoLoc/rpmfusion-free

/rhel-8-for-x86_64-baseos-rpms=$repoLoc/rhel-8-for-x86_64-baseos-rpms \
/rhel-8-for-x86_64-appstream-rpms=$repoLoc/rhel-8-for-x86_64-appstream-rpms \
/codeready-builder-for-rhel-8-x86_64-rpms=$repoLoc/codeready-builder-for-rhel-8-x86_64-rpms
)


# Create Dir if needed
MAKEDIR () {
if [ ! -d "$isoPath" ]; then
  echo "${MAGENTA} MAKING DIRECTORY FOR ISOS ${NC}"
  mkdir -p $isoPath
fi
}

# Clean if more than 4 ISOs
CLEANISOS () {
echo "${BLUE} REMOVING EXTRA ISO FILES ${NC}"
count=$(ls -1 $isoPath/$isoName*.iso | sort | wc -l)

while [ $count -gt 2 ]
do
	ls -1 $isoPath/$isoName*.iso | sort | while read line; do rm $line; exit 0; done
	count=$(ls -1 $isoPath/EXTRA*.iso| sort | wc -l)
done
}

#MAKE ISO - continer will need pkgs - ... do i need to make iso??? iso should have shasum!
EXTRAISO () {
echo "${BLUE} CREATING NEW REPO ISO ${BOLD}$isoName_$cal.iso ${NC}"
mkisofs -JR -V "$isoName"_$cal \
        -o $isoPath/"$isoName"_$cal.iso -graft-points \
        $isoPoints
}


### RUN

MAKEDIR

for isoName in "${isoNameList[@]}"; do
	for isoPoints in "${isoPointsList[@]}"; do
EXTRAISO
done
done

for isoName in "${isoNameList[@]}"; do
CLEANISOS
done