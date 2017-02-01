# encoding : utf-8
require "<%= engine_name %>beautiful_helper"
<%
  if engine_name.blank?
    b_module = e_module = space_indent = ""
  else
    b_module = "module #{engine_camel}"
    e_module = "end"
    space_indent = "  "
  end
%>
<%= b_module %>
<%= space_indent %>module <%= namespace_for_class %><%= model_pluralize.camelize %>Helper
<%= space_indent %>end
<%= e_module %>