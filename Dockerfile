ARG ELIXIR_VERSION=1.13.4
FROM elixir:${ELIXIR_VERSION}-alpine AS builder

WORKDIR /code

COPY mix.exs mix.lock ./

ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV:-prod}
RUN mix local.hex --force && \
    mix deps.get --only ${MIX_ENV:-prod}

COPY config ./config/
COPY lib ./lib/
COPY priv ./priv/
COPY test ./test/
COPY .formatter.exs ./

RUN mix local.rebar --force && \
    mix compile

# Only do this for the image that is going to be run in prod
# We should build the above part with MIX_ENV=prod, publish the image
# then execute the below statements to thin out the image.
# FROM elixir:${ELIXIR_VERSION}-alpine AS runner
# WORKDIR /code
# ENV MIX_ENV=prod
# COPY --from=builder /code/_build ./_build
# COPY --from=builder /code/deps ./deps
# COPY --from=builder /code/mix.exs /code/mix.lock ./
# RUN mix local.hex --force