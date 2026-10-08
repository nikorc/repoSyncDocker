# CONTAINER CONFIG

docker build -t rh10-reposync .

sudo mkdir -p /srv/repos/rhel10

docker run --rm -it \
  --privileged \
  -v /srv/repos/rhel10:/repos:Z \
  rh10-reposync