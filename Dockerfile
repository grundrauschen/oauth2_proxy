FROM alpine:3.7 as build-stage
LABEL maintainer="Tobias Famulla <dev@famulla.eu>"

# When this Dockerfile was last refreshed (year/month/day)
ENV REFRESHED_AT 2018-04-18
# ENV OAUTH2_PROXY_VERSION 2.2
ENV VERSION=542ef540939cbea0e58f4744a0216b68c9579ff6

ENV GOROOT=/usr/lib/go \
    GOPATH=/gopath \
    GOBIN=/gopath/bin \
    PROJECTPATH=/gopath/src/github.com/bitly/oauth2_proxy

ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin
# Checkout bitly's latest google-auth-proxy code from Github
#ADD https://github.com/bitly/oauth2_proxy/releases/download/v2.2/oauth2_proxy-2.2.0.linux-amd64.go1.8.1.tar.gz /tmp
#RUN tar -xf /tmp/oauth2_proxy-2.2.0.linux-amd64.go1.8.1.tar.gz -C ./bin --strip-components=1 && rm /tmp/*.tar.gz

# Install CA certificates
RUN apk add --no-cache --virtual=build-dependencies ca-certificates git go wget libc-dev

COPY . /gopath/src/github.com/bitly/oauth2_proxy
WORKDIR /gopath/src/github.com/bitly/oauth2_proxy

RUN wget -O /usr/bin/dep https://github.com/golang/dep/releases/download/v0.3.2/dep-linux-amd64 && \
        chmod +x /usr/bin/dep && \
        dep ensure && \
        go install

FROM alpine:3.7
RUN apk add --no-cache ca-certificates
COPY --from=build-stage /gopath/bin/oauth2_proxy /usr/local/bin/
# Expose the ports we need and setup the ENTRYPOINT w/ the default argument
# to be pass in.
EXPOSE 8080 4180
ENTRYPOINT [ "/usr/local/bin/oauth2_proxy" ]
CMD [ "--upstream=http://0.0.0.0:8080/", "--http-address=0.0.0.0:4180" ]
