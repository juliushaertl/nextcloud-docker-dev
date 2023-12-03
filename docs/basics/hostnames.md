# Hostnames

## Using /etc/hosts

In order to use the hostnames provided by the environment you need to add them to the /etc/hosts file (which is the simplest method).

You can do this by running the following command, which will automatically update entires:

```bash
./scripts/update-hosts.sh
```

## dnsmasq to resolve wildcard domains

Instead of adding the individual container domains to `/etc/hosts` a local dns server like dnsmasq can be used to resolve any domain ending with the configured `DOMAIN_SUFFIX` in `.env` to localhost.

For dnsmasq adding the following configuration would be sufficient for `DOMAIN_SUFFIX=.local`:

```
address=/.local/127.0.0.1
```

To run dnsmasq in a container, you can use the following example:

```
docker run --rm -it \
    -e DMQ_DHCP_RANGES=" " \
    -e DMQ_DHCP_DNS=" " \
    -e DMQ_DHCP_GATEWAY=" " \
    -e DMQ_DNS_ADDRESS="address=/.local/127.0.0.1" \
    -p 53:53 \
    -p 53:53/udp \
    drpsychick/dnsmasq:latest 
```

## Use DNS Service Discovery on MacOS

You can also use the `dns-sd` tool on MacOS to advertise the container domains on the network. This is especially useful if you try to connect from an iPhone or iPad, since those devices do not allow to edit the `/etc/hosts` file. Use the tool like this:

```
dns-sd -P nextcloud _http._tcp local 80 nextcloud.local 192.168.0.10
```

Be aware that since this is advertised in the local network, it is not recommended to use it in a network where multiple instances could be running. In this case you might want to change the `DOMAIN_SUFFIX` in `.env` to prevent any collision.
