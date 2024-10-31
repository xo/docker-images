FROM docker.io/library/ubuntu:rolling
ARG VERSION
RUN \
    apt-get update -y \
    && apt-get install -y  \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY \
    ./out/$VERSION/usql \
    /bin/usql
ENV LANG en-US.UTF-8
ENTRYPOINT [ "/bin/usql" ]
