FROM maxtori/opam-postgres:debian as compilation

COPY --chown=functori . ./rarible
WORKDIR ./rarible
RUN $(pg_config --bindir)/pg_ctl start -D ../data && \
opam switch create --no-install . ocaml-system && \
eval $(opam env) && \
make deps && \
make clean && \
make

FROM debian:latest as target
LABEL Description="functori-nft container" Vendor="Functori"

RUN apt-get update && \
apt-get install -y sudo postgresql libcurl4-gnutls-dev librdkafka-dev zlib1g-dev && \
addgroup --system functori && adduser --system --group --shell /bin/sh functori && \
echo 'functori ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
sudo chown functori:functori /var/run/postgresql/

USER functori
WORKDIR /home/functori
RUN mkdir data && $(pg_config --bindir)/initdb -D data -U functori && \
echo 'host all  all    0.0.0.0/0  trust' >> data/pg_hba.conf && \
echo "listen_addresses='*'" >> data/postgresql.conf

COPY --from=compilation --chown=functori /home/functori/rarible/deployment/crawler_config.json /home/functori/rarible/docker/entrypoint.sh /home/functori/rarible/_bin/* /home/functori/

RUN $(pg_config --bindir)/pg_ctl start -D data && ./update_db
EXPOSE 5432
VOLUME  ["/home/functori/data"]
ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "./crawler", "crawler_config.json" ]
