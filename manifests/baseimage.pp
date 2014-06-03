class dockerbuild::baseimage (
  $from             = 'centos',
  $maintainer       = 'anton baranov, abaranov@linux.com',
  $start_cmd        = 'bin/sh -c "while true; do echo 1; sleep1 ; done',
  $sshd_installed   = true,
  $sshd_running     = true,
  $entrypoint       = '/start',
){
  # Validate
  validate_string($from)
  validate_string($maintainer)

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  # ADD start script
  file {"${dockerbuild::conf_d}/baseimage.start":
    ensure  => $dockerbuild::ensure,
    mode    => '0755',
    content => inline_template("<% if @sshd_running -%>
service <%= scope.lookupvar('dockerbuild::params::sshd_service') -%> start
<% end -%>
<%= @start_cmd %>
")
  }

  # baseimage.dockfile
  file {"${dockerbuild::conf_d}/baseimage.dockerfile":
    ensure  => $dockerbuild::ensure,
    content => inline_template("#
# VERSION 0.1
#
FROM <%= @from %>
<% if @maintainer -%>
MAINTAINER <%= @maintainer %>
<% end -%>
<% if @sshd_installed -%>
RUN yum -y install <%= scope.lookupvar('dockerbuild::params::sshd_package') %>
<% end -%>
<% if @sshd_running -%>
RUN chkconfig <%= scope.lookupvar('dockerbuild::params::sshd_service') -%> on
EXPOSE 22
<% end -%>
# Add a start script
ADD <%= scope.lookupvar('dockerbuild::conf_d')-%>/baseimage.start  /start
ENTRYPOINT <%= @entrypoint %>
")
  }




  # Dependecy
  Docker::Image[$from] -> Class['Dockerbuild::Baseimage']
}
