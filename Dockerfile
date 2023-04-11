FROM alpine:3.17

RUN apk --update add varnish varnish-dev git automake autoconf libtool python3 make py-docutils curl jq 

WORKDIR /
RUN  git clone -b 7.0 https://github.com/varnish/varnish-modules.git 
RUN cd /varnish-modules && \
    ./bootstrap && \
    ./configure && \
    make && \
    make check -j 4 && \
    make install
RUN  git clone -b v2.0 git://git.gnu.org.ua/vmod-basicauth.git
RUN cd /vmod-basicauth && \
    ./bootstrap && \
    ./configure && \
    make && \
    make install 
RUN  apk del git automake autoconf libtool python3 make py-docutils 
RUN  rm -rf /var/cache/apk/* /vmod-basicauth /varnish-modules

COPY default.vcl /etc/varnish/default.vcl
COPY start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
