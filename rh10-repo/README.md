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
```bash
[ -d /srv/repos/rhel10 ] || sudo mkdir -p /srv/repos/rhel10
sudo podman run --rm \
  --privileged \
    -v /srv/repos/rhel10:/repos/rhel10:Z \
    -v /etc/rhsm:/etc/rhsm:ro \
    -v /etc/pki/entitlement:/etc/pki/entitlement:ro \
    -v /etc/pki/consumer:/etc/pki/consumer:ro \
    -v /etc/yum.repos.d:/etc/yum.repos.d:ro \
    rhel10-mirror:latest
```