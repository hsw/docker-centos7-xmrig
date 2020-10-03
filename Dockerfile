FROM centos:7
ENV XMRIG_VERSION v6.3.5
RUN yum install -y epel-release centos-release-scl && yum install -y wget bzip2 git devtoolset-9-toolchain cmake3 automake libtool
RUN mkdir -p /usr/src/xmrig && git clone --depth 1 --branch $XMRIG_VERSION https://github.com/xmrig/xmrig.git /usr/src/xmrig
RUN sed -i 's/DonateLevel = [0-9]/DonateLevel = 0/g' /usr/src/xmrig/src/donate.h
RUN cd /usr/src/xmrig/scripts && scl enable devtoolset-9 ./build_deps.sh
WORKDIR /usr/src/xmrig/build
RUN scl enable devtoolset-9 'cmake3 .. -DXMRIG_DEPS=scripts/deps -DCMAKE_BUILD_TYPE=Release' && \
  scl enable devtoolset-9 "make -j$(nproc)"

FROM centos:7
COPY --from=0 /usr/src/xmrig/build/xmrig /usr/bin
ENTRYPOINT ["/usr/bin/xmrig"]
