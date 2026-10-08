# CONTAINER CONFIG

```bash
docker build -t rh10-reposync .
```
```bash
sudo mkdir -p /srv/repos/rhel10
```
```bash
docker run --rm -it \
  --privileged \
  -v /srv/repos/rhel10:/repos:Z \
  rh10-reposync
```