FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/ssl/private /etc/ssl/certs

# Generate a 365-day self-signed SSL certificate and private key
# -x509: Creates a self-signed certificate
# -nodes: Skips passphrase creation so Nginx can start without manual input
# -subj: Provides certificate info non-interactively
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=dmusulas.42.fr"


COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]