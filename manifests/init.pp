# == Class: dockerbuild
#
# Full description of class dockerbuild here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Authors
#
# Author Name <author@domain.com>
#
class dockerbuild (
  $ensure = 'present',
  $conf_d = '/etc/dockerbuild',
) inherits dockerbuild::params {

  $ensure_dir = $ensure ? {
    'present' => 'directory',
    default   => 'absent',
  }

  file {$conf_d:
    ensure => $ensure_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '755',
  }
}
