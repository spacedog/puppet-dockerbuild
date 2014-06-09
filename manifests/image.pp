define dockerbuild::image(
  $image_tag   = $title,
  $maintainer = under,
  $start_cmd  = undef,
  $run        = [],
  $cmd        = [],
  $expose     = [],
  $volumes    = [],
  $add        = {},
){

  if is_array($run)     { validate_array($run) }
  if is_array($cmd)     { validate_array($cmd) }
  if is_array($expose)  { validate_array($expose) }
  if is_array($volumes) { validate_array($volumes) }
  if is_hash($add)      { validate_hash($add) }

  validate_string($maintainer)
  validate_string($image_tag)

  # Base image
  class { 'dockerbuild::baseimage': }

  # Variables
  $dockerfile = "${dockerbuild::conf_d}/${title}.dockerfile"
  $baseimage_dockerfile = "${dockerbuild::conf_d}/baseimage.dockerfile"

  concat {$dockerfile:
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Exec["build_${title}"],
  }

  # Baseimage fragment
  concat::fragment {$baseimage_dockerfile:
    target => $dockerfile,
    content => file($baseimage_dockerfile),
    order  => '00',
  }

  # Image custom staff
  concat::fragment {"${title}_${dockerfile}":
    target  => $dockerfile,
    content => inline_template("
<% if @run -%>
<% @run.each do |r| -%>
RUN <%= r %>
<% end -%>
<% end -%>
<% if @volumes -%>
<% @volumes.each do |v| -%>
VOLUME <%= v %>
<% end -%>
<% end -%>
<% if @cmd -%>
<% @cmd.each do |c| -%>
CMD <%= c %>
<% end -%>
<% end -%>
<% if @expose -%>
<% @expose.each do |e| -%>
EXPOSE <%= e %>
<% end -%>
<% end -%>
<% if @add -%>
<% @add.each do |k,a| -%>
ADD <%= k -%> <%= a %>
<% end -%>
<% end -%>
"),
    order   => '01',
  }

  exec {"build_${title}":
    path        => '/usr/bin',
    command     => "docker build --rm=true -t $image_tag - < $dockerfile",
    refreshonly => true,
  }
}
