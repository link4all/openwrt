#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>

<body>
<div id="header">
  <% /usr/shellgui/progs/main.sbin h_sf %>
  <% /usr/shellgui/progs/main.sbin h_nav '{"active": "wan"}' %>
</div>
<div id="main">
<%
network_str=$(uci show network -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2 | grep -v '6$')
for ifce in $ifces; do
type=;ifname=
eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | cut -d '.' -f3-)
[ -z "$type" ] && [ "$ifname" != "lo" ] && wans="$wans ${ifce}"
done

for wan in $wans; do
proto=;dns=;mtu
type=;ip6assign=;ipaddr=;netmask=	# static
dhcp=	# dhcp
username=;password= # pppoe
pre_exec=$(echo "$network_str" | grep 'network\.'${wan}'\.' | cut -d '.' -f3-)
echo "$pre_exec" | grep -qE "[\']$" || echo "$pre_exec" | grep -qE "[\"]$"
if [ $? -eq 0 ]; then
eval $pre_exec
else
eval $(echo "$pre_exec" | sed -e 's#=#=\"#g' -e 's#$#\"#g')
fi

dns1=$(echo "$dns" | awk '{print $1}')
dns2=$(echo "$dns" | awk '{print $2}')

%>
  <div class="container">
    <div class="header row">
      <h1><%= ${_LANG_Form_Wan_Setting} %>(<%= ${wan} %>)</h1>
      <span id="wanType_<%= ${wan} %>"><%= ${_LANG_Form_Watting_for_connection_check} %>...</span>
    </div>
    <div class="hidden" id="<%= ${wan} %>_info">
      <table class="table table-hover">
        <tr>
          <th><%= ${_LANG_Form_IP_Address} %></th>
          <td id="<%= ${wan} %>_info_ip"></td>
        </tr>
        <tr>
          <th><%= ${_LANG_Form_Netmask} %></th>
          <td id="<%= ${wan} %>_info_mask"></td>
        </tr>
        <tr>
          <th><%= ${_LANG_Form_Gateway} %></th>
          <td id="<%= ${wan} %>_info_gateway"></td>
        </tr>
        <tr>
          <th>DNS</th>
          <td id="<%= ${wan} %>_info_dns"></td>
        </tr>
        <tr>
          <td colspan='2'>
            <button class="btn btn-default btn-sm show-set-btn" id="<%= ${wan} %>_set_btn"><%= ${_LANG_Form_Set_Wan} %></button>
          </td>
        </tr>
      </table>
    </div>
    <div class="content row status-block" id="wanSet_<%= ${wan} %>">
      <ul class="nav nav-tabs">
        <li class="<% [ "$proto" = "pppoe" ] && printf active %>"><a href="#pppoe_<%= ${wan} %>" data-toggle="tab"><%= ${_LANG_Form_PPPOE} %></a></li>
        <li class="<% [ "$proto" = "dhcp" ] && printf active %>"><a href="#dhcp_<%= ${wan} %>" data-toggle="tab"><%= ${_LANG_Form_DHCP} %></a></li>
        <li class="<% [ "$proto" = "static" ] && printf active %>"><a href="#static_<%= ${wan} %>" data-toggle="tab"><%= ${_LANG_Form_Static} %></a></li>
      </ul>

      <div class="tab-content col-md-4">

        <div class="tab-pane <% [ "$proto" = "pppoe" ] && printf active %>" id="pppoe_<%= ${wan} %>">
          <form class="form-horizontal" name='pppoe' id="<%= ${wan} %>_pppoe" disabled>
            <div class="form-group">
              <label for="account" class="col-sm-3 control-label"><%= ${_LANG_Form_Username} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="username" value="<%= $username %>" placeholder="<%= ${_LANG_Form_Username} %>">
              </div>
            </div>
            <div class="form-group">
              <label for="password" class="col-sm-3 control-label"><%= ${_LANG_Form_Password} %></label>
              <div class="col-sm-9">
                <input type="password" disabled class="form-control" name="password" value="<%= $password %>" placeholder="<%= ${_LANG_Form_Password} %>">
              </div>
            </div>
            <div class="form-group">
              <label for="mtu" class="col-sm-3 control-label">MTU</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="mtu" value="<%= $mtu %>" placeholder="1500">
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-9">
                <button type="submit" disabled class="btn btn-default" data-order="<%= ${wan} %>"><%= ${_LANG_Form_Apply} %></button>
              </div>
            </div>
          </form>
        </div>
        <div class="tab-pane <% [ "$proto" = "dhcp" ] && printf active %>" id="dhcp_<%= ${wan} %>">
          <form class="form-horizontal" name="dhcp" disabled>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-9">
                <button type="submit" disabled class="btn btn-default" data-order="<%= ${wan} %>"><%= ${_LANG_Form_Apply} %></button>
              </div>
            </div>
          </form>
        </div>
        <div class="tab-pane <% [ "$proto" = "static" ] && printf active %>" id="static_<%= ${wan} %>">
          <form class="form-horizontal" name="static" disabled>
            <div class="form-group">
              <label for="ipadr" class="col-sm-3 control-label"><%= ${_LANG_Form_IP_Address} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="ipaddr" placeholder="<%= ${_LANG_Form_IP_Address} %>">
              </div>
            </div>
            <div class="form-group">
              <label for="netmask" class="col-sm-3 control-label"><%= ${_LANG_Form_Netmask} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="netmask" placeholder="<%= ${_LANG_Form_Netmask} %>">
              </div>
            </div>
            <div class="form-group">
              <label for="gate" class="col-sm-3 control-label"><%= ${_LANG_Form_Gateway} %></label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="gateway" placeholder="<%= ${_LANG_Form_Gateway} %>">
              </div>
            </div>
            <div class="form-group">
              <label for="dns1" class="col-sm-3 control-label">DNS1</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="dns1" value="<%= $dns1 %>" placeholder="8.8.8.8">
              </div>
            </div>
            <div class="form-group">
              <label for="dns2" class="col-sm-3 control-label">DNS2</label>
              <div class="col-sm-9">
                <input type="text" disabled class="form-control" name="dns2" value="<%= $dns2 %>" placeholder="8.8.4.4">
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-9">
                <button type="submit" disabled class="btn btn-default" data-order="<%= ${wan} %>"><%= ${_LANG_Form_Apply} %></button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

<%
done
%>
</div>
<% /usr/shellgui/progs/main.sbin h_f%>
<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<% /usr/shellgui/progs/main.sbin h_end '{"js":["/apps/wan/wan.js"]}'
%>
</body>
</html>