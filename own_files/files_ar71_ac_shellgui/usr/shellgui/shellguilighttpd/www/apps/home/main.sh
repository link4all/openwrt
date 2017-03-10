#!/usr/bin/haserl
<%
if shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null; then
	if [ "$FORM_app" != "home" ]; then
		printf "Location: /?app=wifi\r\n\r\n";exit
	fi
else
	printf "Location: /?app=login\r\n\r\n";exit
fi
%>

<%
# 检查是否是存在home缓存
if [ ! -f /tmp/home.json ]; then
/usr/shellgui/progs/main.sbin h_ji
fi
# eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' home)
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
# '{"title": "路由器用户管理界面", "js":["\/apps\/home\/common\/js\/lan.js"]}'
%>

<body>

<div id="header">
  <% /usr/shellgui/progs/main.sbin h_sf %>
  <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>

  <div id="main">
<%
home_json=$(jshon -e "i18n" < /tmp/home.json)
for type in $(echo "$home_json" | jshon -e "${COOKIE_lang}" -k | sort -n); do
%>
    <div class="container">
      <div class="header">
        <h1 id="<%= ${type} %>"><%= ${type} %></h1>
      </div>
      <div class="content row row">
<% OLD_IFS="$IFS"; IFS=$'\x0A'; for app in $(echo "$home_json" | jshon -e "${COOKIE_lang}" -e "${type}" -k | sort -n); do
		for key in "hidden" "app_name" "desc"; do
		eval "${key}=\"$(echo "$home_json" | jshon -e "${COOKIE_lang}" -e "${type}" -e "${app}" -e ${key} -u 2>/dev/null)\""
		done
		[ $hidden -gt 0 ] && continue
%>
        <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6 app">
          <a href="/?app=<%= ${app_name} %>"><img class="app-img" src="/apps/<%= ${app_name} %>/icon.png" alt="<%= ${desc} %>">
            <h2 class="app-title"><%= ${app} %></h2>
          </a>
        </div>
	<% done %>
    </div>
  </div>	<!-- class="container" -->
<%
done
IFS="$OLD_IFS"
%>


</div>	<!-- id="main" -->

<% /usr/shellgui/progs/main.sbin h_f%>

<% /usr/shellgui/progs/main.sbin h_end %>
</body>

</html>


