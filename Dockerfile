FROM elixir:1.12.3
WORKDIR /opt/app

RUN mix local.hex --force && \
  mix local.rebar --force
