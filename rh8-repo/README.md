# CONTAINER CONFIG
```bash
docker build -t rh8-reposync .
```
```bash
sudo mkdir -p /srv/repos/rhel8
```
```bash
docker run --rm -it \
  --privileged \
  -v /srv/repos/rhel9:/repos:Z \
  rh8-reposync
```bash