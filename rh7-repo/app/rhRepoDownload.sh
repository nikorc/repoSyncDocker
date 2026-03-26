#!/bin/bash
######
## DESC: Performs Reposync of RHEL BaseOS, AppStream, & CodeReady Official Repos; lastes pkgs only.
## AUTHOR: Nic Colombey
## DATE:  2025-07-27
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

# RHEL9 Repos List
repoSrcList=(
rhel-7-server-rpms                                                                                                                   
rhel-7-server-extras-rpms
rhel-7-server-optional-rpms
rhel-7-server-rh-common-rpms
rhel-7-server-supplementary-rpms
)
# Clean up old Data
CLEANDIR () {
  if [ -d /repoData/$rhVersion/$repoSrc ]; then
    echo "${MAGENTA}REMOVING EXISTING DATA for $repoSrc ${NC}"
    rm -Rf /repoData/$rhVersion/$repoSrc
  fi
}

# Perform Reposync
DOWNLOAD () {
  echo "${BLUE}PERFORMING REPOSYNC FOR $repoSrc ${NC}"
  reposync -n --repo $repoSrc -q -p /repoData/$rhVersion/
}

# Run Functions
for repoSrc in "${repoSrcList[@]}"; do
	CLEANDIR
	DOWNLOAD
done
