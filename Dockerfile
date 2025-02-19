ARG UID=200015
ARG GID=200015
ARG WORKDIR=/data

FROM golang:alpine AS builder

RUN apk -U upgrade 
RUN go install software.sslmate.com/src/certspotter/cmd/certspotter@latest

# ======================================= #

FROM alpine

LABEL maintainer="Thien Tran contact@tommytran.io"

ARG UID
ARG GID
ARG WORKDIR

RUN apk -U upgrade \
  && apk add libstdc++

RUN --network=none \
  addgroup -g ${GID} certspotter \
  && adduser -u ${UID} --ingroup certspotter --disabled-password --system certspotter

WORKDIR ${WORKDIR}
ENV CERTSPOTTER_CONFIG_DIR=${WORKDIR}
ENV CERTSPOTTER_STATE_DIR=${WORKDIR}

USER certspotter

COPY --from=builder /go/bin/certspotter /usr/bin/
COPY --from=ghcr.io/polarix-containers/hardened_malloc:latest /install /usr/local/lib/
ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"

ENTRYPOINT /usr/bin/certspotter