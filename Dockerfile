FROM centos:7
RUN sed -i -e '/^mirrorlist/d;/^#baseurl=/{s,^#,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS*.repo
RUN yum install -y epel-release centos-release-scl ca-certificates
RUN sed -i -e '/^mirrorlist/d;/^#\s*baseurl=/{s,^#\s*,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS-SCLo*.repo
RUN yum install -y wget bzip2 git devtoolset-11-toolchain cmake3 automake libtool perl-IPC-Cmd

ARG XMRIG_VERSION=v6.25.0
RUN mkdir -p /usr/src/xmrig && git clone --depth 1 --branch $XMRIG_VERSION https://github.com/xmrig/xmrig.git /usr/src/xmrig
RUN sed -i 's/DonateLevel = [0-9]/DonateLevel = 0/g' /usr/src/xmrig/src/donate.h
RUN cd /usr/src/xmrig/scripts && scl enable devtoolset-11 ./build_deps.sh
WORKDIR /usr/src/xmrig/build
RUN scl enable devtoolset-11 'cmake3 .. -DXMRIG_DEPS=scripts/deps -DCMAKE_BUILD_TYPE=Release' && \
  scl enable devtoolset-11 "make -j$(nproc)"

FROM centos:7
COPY --from=0 /usr/src/xmrig/build/xmrig /usr/bin
ENTRYPOINT ["/usr/bin/xmrig"]
