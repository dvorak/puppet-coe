# This class installs a patch to nova that enables RabbitMQ HA support.
# Addresses bug: https://bugs.launchpad.net/oslo/+bug/856764
#
class coe::patch::nova-rabbitmq (
) {

  include coe::patch
  
  file { "/tmp/impl_kombu.py.patch":
    ensure => present,
    source => 'puppet:///modules/coe/impl_kombu.py.patch'
  }
  
  exec { "patch-nova":
    unless    => '/bin/grep self.channel_errors /usr/lib/python2.7/dist-packages/nova/openstack/common/rpc/impl_kombu.py',
    command   => '/usr/bin/patch -p1 -d /usr/lib/python2.7/dist-packages/nova </tmp/impl_kombu.py.patch',
    require   => [[File['/tmp/impl_kombu.py.patch']],[Package['patch', 'python-nova']]],
  } ->
  # Do this BEFORE any nova scheduler is started, otherwise
  # queues will be declared in non-HA mode which cannot be fixed
  # without erasing the Rabbit database.
  Package<| name == 'nova-scheduler' |>
}
