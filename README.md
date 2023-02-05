### Prerequisites
```
#
yum install -y deltarpm bash
yum install -y bash && ln -svf bash /bin/sh
yum install -y epel-release && yum makecache
yum upgrade -y epel-release && yum makecache
yum install -y binutils util-linux findutils socat ethtool iptables ebtables ipvsadm ipset psmisc bash-completion conntrack-tools iproute nfs-utils
# For openssh
yum install -y initscripts fipscheck fipscheck-lib libedit tcp_wrappers-libs
# For iproute2
yum install -y zlib pcre libselinux libmnl libnetfilter_conntrack libnfnetlink libdb libcap libattr iptables glibc elfutils-libelf
yum install -y iproute iproute-devel
# For wget built against openssl 1.1.1
yum install -y c-ares pcre2 idn2 libidn2 libunistring libuuid glibc
# Install tools
yum install -y wget ca-certificates git less psmisc procps-ng lsof file sed gawk grep patch \
    groff-base pkgconfig shadow-utils diffutils xz xz-libs bzip2 lbzip2 gzip zstd libzstd \
    zip unzip tar cpio dracut vim net-tools iputils crontabs cronie which redhat-rpm-config
rm -fr /tmp/jq-linux64.bin && wget -q -c -t 5 -T 9 "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64" \
    -O /tmp/jq-linux64.bin && install -v -c -m 0755 /tmp/jq-linux64.bin /usr/bin/jq && rm -f /tmp/jq-linux64.bin
yum install -y chrony

#
```

### To sync time using chrony
```
systemctl daemon-reload >/dev/null 2>&1 || : 
systemctl stop chronyd.service >/dev/null 2>&1 || : 
sed -e '/^server /d' \
    -e '/^pool /d' \
    -e '/^#.*pool.ntp.org/d' \
    -e 's|#\(driftfile\)|\1|' \
    -e 's|#\(rtcsync\)|\1|' \
    -e 's|#\(keyfile\)|\1|' \
    -e 's|#\(leapsectz\)|\1|' \
    -e 's|#\(logdir\)|\1|' \
    -i /etc/chrony.conf
sed -e '1i'\
'server time.apple.com iburst\n'\
'server time1.apple.com iburst\n'\
'server time2.apple.com iburst\n'\
'server time3.apple.com iburst\n'\
'server time4.apple.com iburst\n'\
'server time5.apple.com iburst\n'\
'server time1.google.com iburst\n'\
'server time2.google.com iburst\n'\
'server time3.google.com iburst\n'\
'server time4.google.com iburst' \
-i /etc/chrony.conf
systemctl start chronyd.service >/dev/null 2>&1 || : 
systemctl enable chronyd.service >/dev/null 2>&1 || : 
```

### Patches
```
( cp -f dracut-98systemd-module-setup.patch /usr/lib/dracut/ && \
cd /usr/lib/dracut && \
patch --verbose -N -p1 -i dracut-98systemd-module-setup.patch )
# or git apply dracut-98systemd-module-setup.patch

( cp -f redhat-rpm-config.patch /usr/lib/rpm/redhat/ && \
cd /usr/lib/rpm/redhat && \
patch --verbose -N -p1 -i redhat-rpm-config.patch )

```

### To fix "systemd: Can't open PID file /var/run/rhnsd.pid (yet?)" only for RHEL 7
```
./fix-cannot-open-rhnsd.pid.sh
```
