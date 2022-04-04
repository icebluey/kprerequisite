#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

_os_id="$(cat /etc/os-release | grep '^ID=' | cut -d"=" -f2 | sed 's|"||g')"
if [[ ${_os_id} != "rhel" ]]; then
    echo
    printf "\e[01;31m%s\e[0m\n" 'This OS is not a "Red Hat Enterprise Linux Server"'
    echo Aborted
    exit 1
fi

# fix "systemd: Can't open PID file /var/run/rhnsd.pid (yet?) after start: No such file or directory"
[ -d /etc/systemd/system/rhnsd.service.d ] || (
install -m 0755 -d /etc/systemd/system/rhnsd.service.d
echo -e '[Service]\nExecStartPost=/bin/sleep 0.1' > /etc/systemd/system/rhnsd.service.d/override.conf
chmod 0644 /etc/systemd/system/rhnsd.service.d/override.conf
systemctl daemon-reload
systemctl restart rhnsd.service >/dev/null 2>&1 
)

exit
