FROM postgres
RUN \
  DEBIAN_FRONTEND=noninteractive make-ssl-cert generate-default-snakeoil --force-overwrite \
  && cp /etc/ssl/certs/ssl-cert-snakeoil.pem /var/lib/postgresql/server.crt \
  && cp /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/server.key \
  && chown postgres:postgres /var/lib/postgresql/server.crt \
  && chown postgres:postgres /var/lib/postgresql/server.key \
  && chmod 0600 /var/lib/postgresql/server.crt \
  && chmod 0600 /var/lib/postgresql/server.key \
  && perl -pi -e "s%^#ssl%ssl%" /usr/share/postgresql/*/postgresql.conf.sample \
  && perl -pi -e "s%^ssl =.*%ssl = on%" /usr/share/postgresql/*/postgresql.conf.sample \
  && perl -pi -e "s%^ssl_cert_file = .*%ssl_cert_file = '/var/lib/postgresql/server.crt'%" /usr/share/postgresql/*/postgresql.conf.sample \
  && perl -pi -e "s%^ssl_key_file = .*%ssl_key_file = '/var/lib/postgresql/server.key'%" /usr/share/postgresql/*/postgresql.conf.sample
