# Full Text Search

To use Full Text Search, follow these commands :

```bash
docker compose down -v
docker compose up nextcloud proxy elasticsearch elasticsearch-ui
```

You can add another services from `docker-compose.yaml` if you want.

- Address for configuring in Nextcloud: `http://elastic:elastic@elasticsearch:9200`
- Adress to access elastic search from outside: `http://elastic:elastic@elasticsearch.local`
- Address for accessing the ui: http://elasticsearch-ui.local/

```bash
sudo sysctl -w vm.max_map_count=262144
```

