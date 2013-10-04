#
# This module will expose the functionality for users
# to alter the log level for open vswitch
#
define coe::ovs(
  $facility  = 'facility',
  $log_level = 'log_level',
){
  exec {"$name":
    command  => "/usr/bin/ovs-appctl vlog/set ${name}:${facility}:${log_level}",
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    require  => Service['openvswitch'],
  }
}
