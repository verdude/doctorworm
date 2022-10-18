FROM ubuntu:jammy AS erlj
RUN apt-get update && apt-get install ca-certificates make curl git erlang -y --no-install-recommends
RUN set -eux; \
  curl -O https://s3.amazonaws.com/rebar3/rebar3; \
  chmod 555 rebar3; \
  install rebar3 /usr/local/bin/rebar3


FROM erlj AS base
RUN set -eux; \
  apt-get install -y gosu; \
  rm -rf /var/lib/apt/lists/*; \
  gosu nobody true
COPY buildentry.sh /usr/local/bin/entrypoint.sh
RUN chmod 555 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


FROM base as build
RUN mkdir /usr/local/src/dworm
WORKDIR /usr/local/src/dworm
COPY . /usr/local/src/dworm
RUN rebar3 tar

FROM ubuntu:jammy
WORKDIR /opt/
COPY --from=build /usr/local/src/dworm/_build/rel/default/dworm_release/dworm_release-1.tar.gz /opt/
RUN tar xf dworm_release-1.tar.gz
EXPOSE 22884
CMD ["bin/dworm_release", "foreground"]
