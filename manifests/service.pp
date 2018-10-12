# A description of what this defined type does
#
# @summary Manage a container as a systemd service. The container must be defined beforehand using `container`
#
# @example
#   containers::service { 'my_container': }
define containers::service(
    String $service_name = $title
    Optional[Boolean] $service_active = true,
    Optional[Boolean] $service_enable = true,
) {
    $container = $title

    $_unitfile = @("EOF")
    [Unit]
    Description=Podman container ${container}
    Wants=syslog.service

    [Service]
    ExecStart=/usr/bin/podman start --sig-proxy -a ${container}
    ExecStop=/usr/bin/podman stop ${container}
    [Install]
    WantedBy=multi-user.target
    | EOF

    systemd::unit_file { "${service_name}.service":
        content => $_unitfile,
        enable  => $service_enable,
        active  => $service_active,
        require => Container[$container],
    }
}
