# CONTAINER CONFIG

Default locations
repoData = /repoData/repos
repoConfigs = /repoData/repoConfigs

podman run -it -c /path/to/repos:/repoData:Z -v /path/to/config_files:/repoconfigs:Z localhost/rh9repo-test