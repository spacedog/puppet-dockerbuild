define dockerbuild::image(
  $maintainer = undef,
  $start_cmd  = undef,
  $run        = [],
  $cmd        = [],
  $expose     = [],
  $add        = {},
){

  if is_array($run)    { validate_array($run) }
  if is_array($cmd)    { validate_array($cmd) }
  if is_array($expose) { validate_array($expose) }
  if is_hash($add)     { validate_hash($add) }

  class { 'dockerbuild::baseimage':
  }
  $dockerfile = "${dockerbuild::conf_d}/${title}.dockerfile"
  $baseimage_dockerfile = "${dockerbuild::conf_d}/baseimage.dockerfile"

  concat {$dockerfile:
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
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

}
