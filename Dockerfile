FROM arm64v8/ubuntu:bionic

# Copy postgres binary to /usr/local/bin
COPY postgrest-binary.tar.gz /tmp
RUN  cd /tmp && tar xf postgrest-binary.tar.gz && mv postgrest /usr/local/bin && rm postgrest-binary.tar.gz

# Install postgrest deps
RUN apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends \
        curl ca-certificates xz-utils libc6-arm64-cross libc6-dev libpq5 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY postgrest.conf /etc/postgrest.conf

ENV PGRST_DB_URI= \
    PGRST_DB_SCHEMA=public \
    PGRST_DB_ANON_ROLE= \
    PGRST_DB_POOL=100 \
    PGRST_DB_EXTRA_SEARCH_PATH=public \
    PGRST_SERVER_HOST=*4 \
    PGRST_SERVER_PORT=3000 \
    PGRST_SERVER_PROXY_URI= \
    PGRST_JWT_SECRET= \
    PGRST_SECRET_IS_BASE64=false \
    PGRST_JWT_AUD= \
    PGRST_MAX_ROWS= \
    PGRST_PRE_REQUEST= \
    PGRST_ROLE_CLAIM_KEY=".role"

RUN groupadd -g 1000 postgrest && \
    useradd -r -u 1000 -g postgrest postgrest && \
    chown postgrest:postgrest /etc/postgrest.conf

USER 1000

# PostgREST reads /etc/postgrest.conf so map the configuration
# file in when you run this container
CMD exec postgrest /etc/postgrest.conf

EXPOSE 3000
