FROM alpine:3.12.1 as base

LABEL maintainer="Cloud Posse <hello@cloudposse.com>"

LABEL "com.github.actions.name"="Terraform generator"
LABEL "com.github.actions.description"="Generates terraform code that calls terraform module"
LABEL "com.github.actions.icon"="activity"
LABEL "com.github.actions.color"="blue"

# Install the cloudposse alpine repository
ADD https://apk.cloudposse.com/ops@cloudposse.com.rsa.pub /etc/apk/keys/
RUN echo "https://apk.cloudposse.com/3.12/vendor" >> /etc/apk/repositories
RUN echo "https://alpine.global.ssl.fastly.net/alpine/edge/testing" >> /etc/apk/repositories
RUN echo "https://alpine.global.ssl.fastly.net/alpine/edge/community" >> /etc/apk/repositories

RUN apk add -u git
RUN wget https://github.com/mumoshu/variant2/releases/download/v0.37.1/variant_0.37.1_linux_amd64.tar.gz -O /tmp/var.tgz && \
    tar xzf /tmp/var.tgz && \
	rm /tmp/var.tgz && \
	mv variant /usr/local/bin
RUN wget https://github.com/google/go-jsonnet/releases/download/v0.17.0/go-jsonnet_0.17.0_Linux_x86_64.tar.gz -O /tmp/jsonnet.tgz && \
    tar xzf /tmp/jsonnet.tgz && \
	rm /tmp/jsonnet.tgz && \
	mv jsonnet /usr/local/bin

WORKDIR /usr/cli

FROM base as run
# Build the CLI
COPY ./ ./
ENTRYPOINT [ "/usr/cli/main.variant", "--install_dir", "/usr/cli" ]

FROM base as test

RUN apk --no-cache add coreutils ncurses curl bats

ENV LIBS_BATS_MOCK_VERSION="1.3.0" \
    LIBS_BATS_SUPPORT_VERSION="0.3.0" \
    LIBS_BATS_ASSERT_VERSION="0.3.0" \
    LIB_BATS_FILE_VERSION="0.2.0"

# Install bats-support
RUN mkdir -p /usr/local/lib/bats/bats-support \
    && curl -sSL https://github.com/ztombol/bats-support/archive/v${LIBS_BATS_SUPPORT_VERSION}.tar.gz -o /tmp/bats-support.tgz \
    && tar -zxf /tmp/bats-support.tgz -C /usr/local/lib/bats/bats-support --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-support/load.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-support.tgz

# Install bats-assert
RUN mkdir -p /usr/local/lib/bats/bats-assert \
    && curl -sSL https://github.com/ztombol/bats-assert/archive/v${LIBS_BATS_ASSERT_VERSION}.tar.gz -o /tmp/bats-assert.tgz \
    && tar -zxf /tmp/bats-assert.tgz -C /usr/local/lib/bats/bats-assert --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-assert/load.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-assert.tgz

# Install lox's fork of bats-mock
RUN mkdir -p /usr/local/lib/bats/bats-mock \
    && curl -sSL https://github.com/lox/bats-mock/archive/v${LIBS_BATS_MOCK_VERSION}.tar.gz -o /tmp/bats-mock.tgz \
    && tar -zxf /tmp/bats-mock.tgz -C /usr/local/lib/bats/bats-mock --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-mock/stub.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-mock.tgz

# Install bats-file
RUN mkdir -p /usr/local/lib/bats/bats-file \
    && curl -sSL https://github.com/ztombol/bats-file/archive/v${LIB_BATS_FILE_VERSION}.tar.gz -o /tmp/bats-file.tgz \
    && tar -zxf /tmp/bats-file.tgz -C /usr/local/lib/bats/bats-file --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-file/load.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-file.tgz

# Expose BATS_PATH so people can easily use load.bash
ENV BATS_PATH=/usr/local/lib/bats

# Build the CLI
COPY ./ ./
ENTRYPOINT ["bats"]
CMD ["tests/"]

FROM base as local_run
COPY ./ ./
ENTRYPOINT ["/bin/sh"]