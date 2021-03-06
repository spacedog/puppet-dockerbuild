define dockerbuild::build_image(
  $maintainer     = undef,
  $start_cmd      = undef,
  $workdir        = undef,
  $image_tag      = 'latest',
  $from           = 'centos::centos6',
  $run            = [],
  $cmd            = ['/usr/bin/supervisord'],
  $expose         = [],
  $volume         = [],
  $add            = {},
  $do_puppet      = true,
){

  if is_array($run)     { validate_array($run) }
  if is_array($cmd)     { validate_array($cmd) }
  if is_array($expose)  { validate_array($expose) }
  if is_array($volumes) { validate_array($volumes) }
  if is_hash($add)      { validate_hash($add) }

  validate_string(
    $maintainer,
    $image_tag,
    $from,
  )

  # Variables
  $dockerdir  = "${dockerbuild::conf_d}/${name}"
  $dockerfile = "${dockerdir}/Dockerfile"

  file {$dockerdir:
    ensure => 'directory',
  }


  # DockerFile
  concat {$dockerfile:
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # FROM
  concat::fragment {"${name}_Dockerfile_FROM":
    target  => $dockerfile,
    order   => '01',
    content => "FROM ${from}\n",
  }

  # MAINTAINER
  if !empty($maintainer) {
    concat::fragment {"${name}_Dockerfile_MAINTAINER":
      target  => $dockerfile,
      order   => '10',
      content => "MAINTAINER ${maintainer}\n",
    }
  }

  # RUN
  if !empty($run) {
    concat::fragment {"${name}_Dockerfile_RUN":
      target  => $dockerfile,
      order   => '20',
      content => inline_template('<% @run.each do |r| -%>
RUN <%= r %>
<% end -%>'),
     }
  }

  # VOLUMES
  if !empty($volume) {
    concat::fragment {"${name}_Dockerfile_VOLUME":
      target  => $dockerfile,
      order   => '30',
      content => inline_template('<% @volume.each do |v| -%>
VOLUME <%= v %>
<% end -%>'),
    }
  }

  # CMD
  if !empty($cmd) {
    concat::fragment {"${name}_Dockerfile_CMD":
      target  => $dockerfile,
      order   => '40',
      content => inline_template('CMD [<% @cmd.each do |c| %>"<%= c -%>"<% end %>]
'),
    }
  }

  # EXPOSE
  if !empty($expose) {
  concat::fragment {"${name}_Dockerfile_EXPOSE":
      target  => $dockerfile,
      order   => '50',
      content => inline_template('<% @expose.each do |e| -%>
EXPOSE <%= e %>
<% end -%>'),
    }
  }

  # ADD
  if !empty($add) {
    concat::fragment {"${name}_Dockerfile_ADD":
      target  => $dockerfile,
      order   => '60',
      content => inline_template('<% @add.each do |k,a| -%>
ADD <%= k -%> <%= a %>
<% end -%>'),
    }
  }
  if $do_puppet {
    #TODO: find a better way to run puppet during docker build
  }

  Concat[$dockerfile] ~>
  exec {"build_${name}":
    path        => '/usr/bin',
    command     => "docker build --rm=true -t $name:$image_tag . ",
    cwd         => $dockerdir,
    logoutput   => true,
    timeout     => 3600,
    refreshonly => true,
  }
}
