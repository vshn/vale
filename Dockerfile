############################
# STEP 1
############################
FROM docker.io/library/alpine:3.18.4 AS builder

# renovate: datasource=github-releases depName=errata-ai/vale
ENV VALE_VERSION=2.29.1
# renovate: datasource=github-releases depName=errata-ai/Microsoft
ENV MS_STYLE_VERSION=0.10.1
# renovate: datasource=github-releases depName=testthedocs/Openly
ENV OPENLY_STYLE_VERSION=0.3.1

# Install build tools
RUN apk add --no-cache wget zip tar
WORKDIR /

RUN wget -q https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz && \
    tar -xzf vale_${VALE_VERSION}_Linux_64-bit.tar.gz

# Install Microsoft style file
RUN wget -q https://github.com/errata-ai/Microsoft/releases/download/v${MS_STYLE_VERSION}/Microsoft.zip && \
    unzip -qq Microsoft.zip

# Install Openly style file
RUN wget -q https://github.com/testthedocs/Openly/releases/download/${OPENLY_STYLE_VERSION}/Openly.zip && \
    unzip -qq Openly.zip && \
    sed -i 's|openly|Openly|g' Openly/Spelling.yml

############################
# STEP 2
############################
FROM docker.io/library/alpine:3.18.4

RUN apk add --update --no-cache \
    python3 \
    py-pip \
    asciidoctor \
    git \
    libc6-compat \
   && pip install docutils

# Copy our static executable.
COPY --from=builder /vale      /usr/local/bin/vale
COPY --from=builder /Microsoft /styles/Microsoft
COPY --from=builder /Openly    /styles/Openly
COPY vale.ini /.vale.ini
COPY Vocab /styles/Vocab

ENTRYPOINT ["/usr/local/bin/vale"]
