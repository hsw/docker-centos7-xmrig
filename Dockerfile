FROM centos:7
ENV XMRIG_VERSION v5.5.3
RUN yum install -y epel-release && yum install -y wget bzip2 git make cmake3 gcc gcc-c++ automake libtool autoconf libstdc++-static
RUN mkdir -p /usr/src/xmrig && git clone --depth 1 --branch $XMRIG_VERSION https://github.com/xmrig/xmrig.git /usr/src/xmrig
RUN sed -i 's/DonateLevel = \d+/DonateLevel = 0/g' /usr/src/xmrig/src/donate.h
RUN cd /usr/src/xmrig/scripts && ./build_deps.sh
RUN mkdir /usr/src/xmrig/build && cd /usr/src/xmrig/build && \
  cmake3 .. -DXMRIG_DEPS=scripts/deps -DCMAKE_BUILD_TYPE=Release && \
  make -j$(nproc)

FROM centos:7
COPY --from=0 /usr/src/xmrig/build/xmrig /usr/bin
ENTRYPOINT ["/usr/bin/xmrig"]