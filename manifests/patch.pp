# Class to ensure the necessary packages are present
# to patch OpenStack services.
#
class coe::patch {
  package { 'patch':
    ensure => present,
  }
}
