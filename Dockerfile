ARG UID=200015
ARG GID=200015

FROM golang:alpine AS builder

RUN apk -U upgrade 
RUN go install software.sslmate.com/src/certspotter/cmd/certspotter@latest

# ======================================= #

FROM alpine

LABEL maintainer="Thien Tran contact@tommytran.io"

ARG UID
ARG GID

RUN apk -U upgrade \
  && apk add libstdc++

RUN --network=none \
  addgroup -g ${GID} certspotter \
  && adduser -u ${UID} --ingroup certspotter --disabled-password --system certspotter

WORKDIR /home/certspotter/
USER certspotter

RUN mkdir -p /home/certspotter/.certspotter \
    # Support changing UID/GID by the sysadmin
    && chmod 755 /home/certspotter/ /home/certspotter/.certspotter

COPY --from=builder --chown=root:root --chmod=755 /go/bin/certspotter /usr/bin/
COPY --from=ghcr.io/polarix-containers/hardened_malloc:latest /install /usr/local/lib/
ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"

ENTRYPOINT /usr/bin/certspotter