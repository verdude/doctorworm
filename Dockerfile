FROM erlang:25 AS base
RUN set -eux; \
	apt-get update; \
	apt-get install -y gosu make; \
	rm -rf /var/lib/apt/lists/*; \
	gosu nobody true
COPY buildentry.sh /usr/local/bin/entrypoint.sh
RUN chmod 555 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


FROM base as build
RUN mkdir /usr/local/src/doctorworm
WORKDIR /usr/local/src/doctorworm
COPY . /usr/local/src/doctorworm
RUN make
