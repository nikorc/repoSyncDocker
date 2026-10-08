docker build -t NAME .
docker run -it -v /repoData/repos:/repoData:Z -v /repoData/repoConfigs:/repoConfigs:Z IMG_ID

Run getGPG-Keys.sh to get keys download to /srv/rhelX