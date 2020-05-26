# Monitoring

The hosts for the containers are vital to the whole system. Therefore it is suggested to monitor them. This helps with placement of new containers too.

A solid approach is to use the prometheus node exporter as explained below

## Prometheus Grafana Stack

Please deploy a Prometheus Grafana stack.

## Nodes

For the nodes to provide metrics, they need to export them via `node_exporter`.
Unfortunately the current version does not support basic auth and TLS. Therefore use a reverse proxy and there is no excuse for not using TLS with valid certificates.

### Installation

    apt-get install prometheus-node-exporter nginx certbot python3-certbot-nginx
    
### Node Exporter

To hide the node exporter to localhost and include the btrfs mounts, change `/etc/default/prometheus-node-exporter`

    ARGS="--web.listen-address=\"127.0.0.1:9100\" --collector.filesystem.ignored-mount-points=\"^/(dev|proc|run|sys|mnt|var/lib/docker|snap)($|/)\""

and restart the service

### Reverse Proxy

The nginx provides TLS and Basic Auth. Add a section to `/etc/nginx/sites-enabled/default`
    
    location /metrics {
        proxy_pass http://localhost:9100;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_buffering off;
        proxy_request_buffering off;

        auth_basic       "Scraper’s Area";
        auth_basic_user_file /etc/nginx/.htpasswd; 
    }
    
Set the correct `server_name` from `_` to:

    server_name public.dns.tld;
 
And provide a htpasswd formated user in `/etc/nginx/.htpasswd`

Then run

    sudo certbot --nginx

## Prometheus

To your prometheus config add a job:

      - job_name: 'nodeexporter'
        scrape_interval: 1m
        scheme: https
        basic_auth:
          username: scrape
          password: ***
        static_configs:
          - targets: 
             - 'public.dns.tld' 

and reload the config.

## Grafana

Then design a dashboard as you please.