# CONTAINER CONFIG
```bash
docker build -t rh9-reposync .
```
```bash
sudo mkdir -p /srv/repos/rhel9
```
```bash
docker run --rm -it \
  --privileged \
  -v /srv/repos/rhel9:/repos:Z \
  rh9-reposync
```bash