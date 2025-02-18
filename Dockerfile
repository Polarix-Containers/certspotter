ARG UID=200015
ARG GID=200015

FROM golang:alpine

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

RUN go install software.sslmate.com/src/certspotter/cmd/certspotter@latest

ENTRYPOINT /home/certspotter/bin/certspotter