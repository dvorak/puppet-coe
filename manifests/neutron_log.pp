#
# Add overriding rsyslog config file suppressing overzealous sudo logs
# from the Ubuntu default neutron rootwrap configuration

class coe::neutron_log {

    package { 'rsyslog':
        ensure  => 'installed',
    }

    file { '/etc/rsyslog.d/00-neutron_sudo.conf':
        ensure  => 'file',
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        require => Package['rsyslog'],
        content => template('coe/neutron_sudo_ubuntu.erb'),
        notify  => Service['rsyslog'],
    }

    service { 'rsyslog':
        ensure  => 'running',
        enable  => true,
        require => Package['rsyslog'],
    }

    file_line { 'neutron_sudoers_loglevels':
        ensure    => 'present',
        line      => 'Defaults:neutron syslog_badpri=err, syslog_goodpri=info',
        path      => '/etc/sudoers.d/neutron_sudoers',
        subscribe => Package['neutron'],
    }

}
