############################
# STEP 1
############################
FROM docker.io/library/golang:alpine AS builder

# Install build tools
RUN apk update && apk add --no-cache wget zip tar
WORKDIR /

RUN wget -q https://github.com/errata-ai/vale/releases/download/v2.15.4/vale_2.15.4_Linux_64-bit.tar.gz && \
    tar -xzf vale_2.15.4_Linux_64-bit.tar.gz

# Install Microsoft style file
RUN wget -q https://github.com/errata-ai/Microsoft/releases/download/v0.9.0/Microsoft.zip && \
    unzip -qq Microsoft.zip

# Install Openly style file
RUN wget -q https://github.com/testthedocs/Openly/releases/download/0.3.1/Openly.zip && \
    unzip -qq Openly.zip

############################
# STEP 2
############################
FROM docker.io/library/alpine:3.18.0

RUN apk add --update \
    python3 \
    py-pip \
    asciidoctor \
    git \
    libc6-compat \
   && pip install docutils \
   && rm -rf /var/cache/apk/*

# Copy our static executable.
COPY --from=builder /vale /usr/local/bin/vale
COPY --from=builder /Microsoft /styles/Microsoft
COPY --from=builder /Openly /styles/Openly
COPY vale.ini /.vale.ini
COPY Vocab /styles/Vocab

ENTRYPOINT ["/usr/local/bin/vale"]
