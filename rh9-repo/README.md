# CONTAINER CONFIG

docker build -t rh9-reposync .

sudo mkdir -p /srv/repos/rhel9

docker run --rm -it \
  --privileged \
  -v /srv/repos/rhel9:/repos:Z \
  rh9-reposync