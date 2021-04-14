# Docker mktxp

![License](https://img.shields.io/badge/License-GNU%20GPL-blue.svg)
![License](https://img.shields.io/badge/mikrotik-routeros-orange)
![License](https://img.shields.io/badge/prometheus-exporter-blueviolet)

This is a port to Docker and is build from the project [akpw/mktxp](https://github.com/akpw/mktxp) on Github.

## Description
MKTXP is a Prometheus Exporter for Mikrotik RouterOS devices.
It gathers and exports a rich set of metrics across multiple routers, all easily configurable via built-in CLI interface. 

For effortless visualization of the RouterOS metrics exported to Prometheus, MKTXP comes with a dedicated [Grafana dashboard](https://grafana.com/grafana/dashboards/13679):

<img src="https://akpw-s3.s3.eu-central-1.amazonaws.com/mktxp_black.png" width="400" height="620">




### Getting started:

#### 1. Mikrotik Device Config
For the purpose of RouterOS device monitoring, it's best to create a dedicated user with minimal required permissions. \
MKTXP only needs ```API``` and ```Read```, so at that point you can go to your router's terminal and type:
```
/user group add name=mktxp_group policy=api,read
/user add name=mktxp_user group=mktxp_group password=mktxp_user_password
```

#### 2. mktxp first time setup

The easiest way is to get a configuration is, start mktxp Container and edit the configuration Template with the editor nano.

```
docker run -it --rm -v ./mktxp_config:/root/mktxp:rw guenterbailey/mktxp mktxp edit -ed nano
```

```
[Sample-Router]
    enabled = True         # turns metrics collection for this RouterOS device on / off

    hostname = 192.168.2.254    # RouterOS IP address
    port = 8728             # RouterOS IP Port

    username = prometheus     # RouterOS user, needs to have 'read' and 'api' permissions
    password = top-secret

    use_ssl = False                 # enables connection via API-SSL servis
    no_ssl_certificate = False      # enables API_SSL connect without router SSL certificate
    ssl_certificate_verify = False  # turns SSL certificate verification on / off

    dhcp = True                     # DHCP general metrics
    dhcp_lease = True               # DHCP lease metrics
    pool = True                     # Pool metrics
    interface = True                # Interfaces traffic metrics
    firewall = True                 # Firewall rules traffic metrics
    monitor = True                  # Interface monitor metrics
    poe = True                      # POE metrics
    route = True                    # Routes metrics
    wireless = False                 # WLAN general metrics
    wireless_clients = False         # WLAN clients metrics
    capsman = True                  # CAPsMAN general metrics
    capsman_clients = True          # CAPsMAN clients metrics

    use_comments_over_names = True  # when available, forces using comments over the interfaces names
```


After the configuration setup, start the docker container and check with *mktxp print -en Sample-Router -cc* if the configuration is valid.


```
docker run -it --rm -v ./mktxp_config:/root/mktxp:rw guenterbailey/mktxp mktxp print -en Sample-Router -cc

Connecting to router Sample-Router@192.168.2.254
2021-04-14 18:42:21 Connection to router Sample-Router@192.168.2.254 has been established
+------------------------+--------------+-------------------+-----------+-----------+-------------+----------+---------+------------+
|       dhcp_name        | dhcp_address |    mac_address    | rx_signal | interface |    ssid     | tx_rate  | rx_rate |   uptime   |
+========================+==============+===================+===========+===========+=============+==========+=========+============+
| 3C:01:EF:07:6D:D6      | 192.168.2.19 | 3C:01:EF:07:6D:D6 |    -87    |   cap6    |  private    | 81 Mbps  | 27 Mbps | 56 minutes |
| MYNB01                 | 192.168.2.99 | 5C:E0:C5:50:C0:1C |    -68    |   cap6    |  private    | 292 Mbps | 12 Mbps | 28 minutes |
|                        |              |                   |           |           |             |          |         |            |
| pzwws                  | 192.168.2.96 | 74:DA:38:41:68:FC |    -83    |   cap5    |  private    | 43 Mbps  | 5 Mbps  |   8 days   |
| 38:78:62:8A:00:98      | 192.168.2.11 | 38:78:62:8A:00:98 |    -65    |   cap5    |  private    | 300 Mbps | 5 Mbps  |  an hour   |
| ESP-CBC78C             | 192.168.2.13 | 18:FE:34:CB:C7:8C |    -51    |   cap5    |  private    | 72 Mbps  | 54 Mbps |   8 days   |
|                        |              |                   |           |           |             |          |         |            |
| ctronics IPCAM Eingang |  10.0.0.245  | 70:F1:1C:53:ED:10 |    -75    |   cap2    |   guest     | 43 Mbps  | 39 Mbps |  18 hours  |
| Galaxy-M31             |   10.0.0.4   | 4E:CD:3D:4D:AB:00 |    -65    |   cap2    |   guest     | 72 Mbps  | 65 Mbps | 14 minutes |
| 28:3F:69:11:1C:D7      |   10.0.0.5   | 28:3F:69:11:1C:D7 |    -57    |   cap2    |   guest     | 72 Mbps  | 1 Mbps  |  5 hours   |
+------------------------+--------------+-------------------+-----------+-----------+-------------+----------+---------+------------+
cap6 clients: 2
cap5 clients: 3
cap2 clients: 3
Total connected CAPsMAN clients: 8 

```

#### 3. start the Container

start the Container in background and add Port Forwarding to **49090**.

```
docker run -it -d -v ./mktxp_config:/root/mktxp:rw -p 0.0.0.0:49090:49090 guenterbailey/mktxp
```

Now we can setup prometheus to scrape our mikrotik exporter.

Open the prometheus.yml config
```
❯ nano /etc/prometheus/prometheus.yml
```

and simply add:

```
  - job_name: 'mktxp'
    static_configs:
      - targets: ['docker-host-ip:49090']

```

After the setup, restart prometheus.

## Grafana dashboard
Now with your RouterOS metrics being exported to Prometheus, it's easy to visualize them with this [Grafana dashboard](https://grafana.com/grafana/dashboards/13679)

### docker-compose.yml

```yaml
version: "3"

services:
  mktxp:
    restart: on-failure
    image: guenterbailey/mktxp:latest
    volumes:
      - ./mktxp_config:/root/mktxp:rw
    ports:
      - "0.0.0.0:49090:49090"
    networks:
      - traefik-proxy

networks:
   traefik-proxy:
        external: true
```

