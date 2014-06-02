class dockerbuild::params {
  $sshd_package = $::osfamily ? {
    'RedHat' => 'openssh-server',
    default  => 'sshd',
  }
  $sshd_service = $::osfamily ? {
    'RedHat' => 'sshd',
    default  => 'ssh',
  }
}
