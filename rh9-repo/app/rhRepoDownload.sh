#/bin/bash
######
## DESC: Performs Reposync of RHEL BaseOS, AppStream, & CodeReady Official Repos; lastes pkgs only.
## AUTHOR: Nic Colombey
## DATE:  2025-07-27
## repoData = Location for Repos to be created
######

# Set Variables
rhVersion=RHEL9.latest

# RHEL9 Repos List
repoList=(
	rhel-9-for-x86_64-baseos-rpms
	rhel-9-for-x86_64-appstream-rpms
	codeready-builder-for-rhel-9-x86_64-rpms
)
# Clean up old Data


# Perform Reposync