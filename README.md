# letsencrypt-Certdumper

Copies the latest Let's Encrypt certificates for a domain into a Docker mail server's SSL directory and restarts the container only when files have actually changed.

## Usage

1. Set `DOMAIN` in `certdumper.sh` to your domain.
2. Adjust `SSL_DIR` if your mail server mounts certificates elsewhere.
3. Run as root (required for `/etc/letsencrypt/archive` access and `chown`):

```sh
sudo bash certdumper.sh
```

Intended to be called from a certbot renewal hook, e.g. `/etc/letsencrypt/renewal-hooks/deploy/certdumper.sh`.

## What it does

- Finds the highest-numbered certificate files in `/etc/letsencrypt/archive/<domain>/`
- Compares each against the currently deployed certificate using `cmp`
- Copies changed files, sets `mail:mail` ownership and `600` permissions
- Restarts the mail server via `docker compose` only if at least one file changed
