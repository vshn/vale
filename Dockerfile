############################
# STEP 1
############################
FROM golang:alpine AS builder

# Install build tools
RUN apk update && apk add --no-cache wget zip tar
WORKDIR /

RUN wget https://github.com/errata-ai/vale/releases/download/v2.6.1/vale_2.6.1_Linux_64-bit.tar.gz
RUN tar -xvzf vale_2.6.1_Linux_64-bit.tar.gz

# Install syntax file
RUN wget https://github.com/errata-ai/Microsoft/releases/download/v0.8.0/Microsoft.zip
RUN unzip Microsoft.zip


############################
# STEP 2
############################
FROM alpine:3.11.6

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
COPY vale.ini /.vale.ini

CMD ["/usr/local/bin/vale"]

