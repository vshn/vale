############################
# STEP 1
############################
FROM golang:alpine AS builder

# Install build tools
RUN apk update && apk add --no-cache wget zip tar make
WORKDIR /

RUN wget https://github.com/errata-ai/vale/archive/v1.7.1.tar.gz
RUN tar -xvzf v1.7.1.tar.gz

WORKDIR /vale-1.7.1
RUN make

# Install syntax file
RUN wget https://github.com/errata-ai/Microsoft/releases/download/v0.6.1/Microsoft.zip
RUN unzip Microsoft.zip


############################
# STEP 2
############################
FROM alpine:latest

RUN apk add --update \
    python \
    py-pip \
    asciidoctor \
   && pip install docutils \
   && rm -rf /var/cache/apk/*

# Copy our static executable.
COPY --from=builder /vale-1.7.1/bin/vale /vale
COPY --from=builder /vale-1.7.1/Microsoft /styles/Microsoft
COPY vale.ini /.vale.ini

ENTRYPOINT ["/vale"]

