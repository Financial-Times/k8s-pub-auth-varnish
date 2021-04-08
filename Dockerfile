FROM alpine:3.9

ENV VARNISHSRC=/usr/include/varnish VMODDIR=/usr/lib/varnish/vmods

COPY vmod-basicauth-1.9/ /vmod-basicauth

RUN apk --update add varnish varnish-dev git automake autoconf libtool python3 make py-docutils curl jq && ln -s /usr/bin/python3 /usr/bin/python && \
  cd / && echo "-------basicauth-build-------" && \
  git clone https://github.com/varnish/varnish-modules.git && \
  mkdir /aclocal && \
  cd varnish-modules && \
  git checkout  f771780801b5cf8b77954226a4f623fac759cd1e && \
  autoreconf -f -i && \
  ./bootstrap && \
  ./configure && \
  make  && \
  make install && \
  cd /vmod-basicauth && \
  autoreconf -f -i && \
  mkdir -p /usr/include/varnish/bin/varnishtest/ && \
  ln -s /usr/bin/varnishtest /usr/include/varnish/bin/varnishtest/varnishtest && \
  mkdir -p /usr/include/varnish/lib/libvcc/ && \
  ln -s /usr/share/varnish/vmodtool.py /usr/include/varnish/lib/libvcc/vmodtool.py && \
  ./configure && \
  make && \
  make install && \
  apk del git automake autoconf libtool python3 make py-docutils && \
  rm -rf /var/cache/apk/* /vmod-basicauth

COPY default.vcl /etc/varnish/default.vcl
COPY start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
