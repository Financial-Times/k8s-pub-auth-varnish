FROM ubuntu:bionic

ENV VARNISHSRC=/usr/include/varnish VMODDIR=/usr/lib/varnish/vmods

WORKDIR /

RUN apt-get update && \
    apt-get install -y curl gnupg2

# install varnish 6.0-lts
RUN curl -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | apt-key add - && \
    echo "deb https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ bionic main" | tee /etc/apt/sources.list.d/varnish-cache.list && \
    apt-get update && \
    apt-get install -y libgetdns-dev varnish=6.0.11-1~bionic varnish-dev=6.0.11-1~bionic

# install varnish-modules
RUN apt-get install -y git automake autoconf libtool python3 make python-docutils jq && \
    git clone -b 6.0-lts https://github.com/varnish/varnish-modules.git && \
    mkdir /aclocal && \
    cd /varnish-modules && \
    autoreconf -f -i && \
    ./bootstrap && \
    ./configure && \
    make  && \
    make install

# install vmod-basicauth
COPY vmod-basicauth-1.9/ /vmod-basicauth
RUN  cd /vmod-basicauth && \
    autoreconf -f -i && \
    mkdir -p /usr/include/varnish/bin/varnishtest/ && \
    ln -s /usr/bin/varnishtest /usr/include/varnish/bin/varnishtest/varnishtest && \
    mkdir -p /usr/include/varnish/lib/libvcc/ && \
    ln -s /usr/share/varnish/vmodtool.py /usr/include/varnish/lib/libvcc/vmodtool.py && \
    ./configure && \
    make && \
    make install

# cleanup
RUN  apt-get remove -y curl gnupg2 git git varnish-dev automake autoconf libtool python3 make python-docutils jq && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /vmod-basicauth

COPY default.vcl /etc/varnish/default.vcl
COPY start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
