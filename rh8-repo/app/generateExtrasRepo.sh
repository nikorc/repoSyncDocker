#!/bin/bash
######
## DESC: Creates custom repo dirs from approved/wanted pgk list. DL from epel, rpmfusion-free, & rpmfussion-nonfree
## AUTHOR: Nic Colombey
## DATE:  2025-07-27
## repoConfig = Location of Approved Extra Packages Lists
## repoData = Location for Repos to be created
######

# Set Colors
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
MAGENTA=$'\e[35m'
YELLOW=$'\e[33m'
BOLD=$'\e[1m'
NC=$'\e[0m' # Resets all formatting

# Set Variables
rhVersion=RHEL$(rpm -E %rhel).latest
approveList=/repoConfigs/$rhVersion/approvedExtras.txt
repoSrcList=(
epel
rpmfusion-free
rpmfusion-nonfree
)

# Establish Config PATHS and FILES
CONFILE () {
if [ -d "/repoConfigs/$rhVersion" ]; then
  mkdir -p /repoConfigs/$rhVersion
fi

if [ ! -f $approveList ]; then
  echo "${RED}CREATING EMPTY APPROVED PACKAGE LIST; POPULATE WITH PKGs WANTED FROM EPEL & RPMFUSSION ${NC}"
  touch "$approveList"
  exit 0
fi
}

# Clean Data
CLEANLIST () {
  if [ -f $pkgList ]; then
    echo "${MAGENTA}REMOVING OLD PACKAGE LIST ${NC}"
    rm $pkgList
  fi
}

CLEANDIR () {
  if [ -d /repoData/$rhVersion/$repoSrc ]; then
    echo "${MAGENTA}REMOVING EXISTING DATA for $repoSrc ${NC}"
    rm -Rf /repoData/$rhVersion/$repoSrc
  fi
}

# Generate package List
GENERATE () {
  echo "${GREEN}CREATING NEW FULL PACKAGE LIST TO DOWNLOAD ${NC}"
  pkgName=$(cat /repoConfigs/$rhVersion/approvedExtras.txt)
  pkgList=/repoConfigs/$rhVersion/listOfExtras.$repoSrc
  dnf install --assumeno $pkgName 2>/dev/null | grep $repoSrc | cut -d" " -f2 > $pkgList
}

# Download packages 
DOWNLOAD () {
  echo "${BLUE}DOWNLOADING PACKAGE LIST FOR $repoSrc ${NC}"
  downList=$(cat $pkgList)
  dnf download $downList -q --destdir /repoData/$rhVersion/$repoSrc/packages
}

# Create repo files
CREATEREPO () {
  echo "${YELLOW}CREATING REPO FOR $repoSrc ${NC}"
  cd /repoData/$rhVersion/$repoSrc
  createrepo -q .
}


######
# Run Functions
CONFILE

for repoSrc in "${repoSrcList[@]}"; do
  echo "${BOLD} CLEAN UP and GENERATION OF PACKAGE LIST $repoSrc ${NC}"
  CLEANDIR
  GENERATE
  if [ -s $pkgList ]; then
    echo "${BOLD}PERFORMING REPO TASKS for $repoSrc ${NC}"
    DOWNLOAD
    CREATEREPO
  else
    echo "${BOLD}NO PACKAGES for $repoSrc ${NC}"
  fi
done