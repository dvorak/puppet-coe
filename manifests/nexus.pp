class coe::nexus (
$nexus_credentials = undef,
$nexus_config      = undef
) 
{
  package { 'python-ncclient':
    ensure => installed,
  } ~> Service['neutron-server']

#  if !defined(File['/etc/neutron/plugins/cisco']) {
#    file { '/etc/neutron/plugins/cisco':
#      ensure => directory,
#      owner  => root,
#      group  => root,
#    }
#  }

  # hack to make sure the directory is created
  Neutron_plugin_cisco<||> ->
  file { '/etc/neutron/plugins/cisco/cisco_plugins.ini':
    owner   => 'root',
    group   => 'root',
    content => template('coe/cisco_plugins.ini.erb'),
  } ~> Service['neutron-server']

  if !$nexus_config {
    fail('No nexus config specified')
  }

  file {'/var/lib/neutron/.ssh':
    ensure => directory,
    owner  => 'neutron',
    require => Package['neutron-server']
  }
  nexus_creds{ $nexus_credentials:
    require => [ File['/var/lib/neutron/.ssh'],
                 File['/etc/neutron/plugins/cisco/cisco_plugins.ini'] ]
  }
}

define nexus_creds {
  $args = split($title, '/')
  neutron_plugin_cisco_credentials {
    "${args[0]}/username": value => $args[1];
    "${args[0]}/password": value => $args[2];
  }
  exec {"${title}":
    unless => "/bin/cat /var/lib/neutron/.ssh/known_hosts | /bin/grep ${args[0]}",
    command => "/usr/bin/ssh-keyscan -t rsa ${args[0]} >> /var/lib/neutron/.ssh/known_hosts",
    user    => 'neutron',
    require => Package['neutron-server']
  }
}

