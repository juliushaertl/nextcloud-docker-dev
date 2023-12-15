# Tips

## Shell aliases

It can be useful to be able to access your setup quickly through your shell. Here are some examples that you could add to your bashrc or zshrc:

## nc-dev

The following shell function allows you to run `nc-dev` instead of `docker compose` in any location. This way you can run for example `nc-dev up -d nextcloud`, `nc-dev exec nextcloud bash` or `nc-dev exec nextcloud occ`.

````
nc-dev() {
 (cd ~/path/to/nextcloud-docker-dev && docker compose $@)
}
```
