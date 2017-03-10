#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
	if [ "${GET_action}" = "bw_status" ] &>/dev/null; then
	id=$(echo ${COOKIE_session} | grep -Eo '.....$')
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		shellgui '{"action": "ifces_bw_status", "session": "'"$id"'"}'
    exit
	elif [ "${GET_action}" = "hw_status" ] &>/dev/null; then
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"

memswap_str=$(shellgui '{"action": "get_mem_status", "readable": 1}' | jshon -j)
        cat <<EOF
{"uptime":$(shellgui '{"action": "get_uptime"}' | jshon -e "formatted" -j),"cpu":$(shellgui '{"action": "get_cpu_usage"}' | jshon -e "detail" -j),"swap":$(echo "$memswap_str" | jshon -e "swap" -j),"mem":$(echo "$memswap_str" | jshon -e "mem" -j)}
EOF
    exit
	fi
	time_now=$(date +%s)
	ls /tmp/bw_last-*.json -l  -e | while read line; do
	time_file=$(date -D "%b %d %H:%M:%S %Y" -d "$(echo "${line}" | awk '{print $7" "$8" "$9" "$10}')" +%s)

	[ $(expr ${time_now} - ${time_file}) -gt 300 ]  && file=$(echo "${line}" | awk '{print $NF}') && rm -f ${file}
	done
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
# '{"title": "路由器用户管理界面", "js":["\/apps\/home\/common\/js\/lan.js"]}'
%>
<body>
<div id="header">
  <% /usr/shellgui/progs/main.sbin h_sf %>
  <% /usr/shellgui/progs/main.sbin h_nav '{"active": "status"}' %>
</div>

<div id="main">
    <div class="container">
      <div class="header">
        <h1><%= ${_LANG_Form_Running_state_of_the_system} %></h1>
      </div>
      <div class="row">
        <div class="col-xs-12">
          <div class="running-time"><%= ${_LANG_Form_Runs} %>: <span id="running-time">0 <%= ${_LANG_Form_Days} %> 00 <%= ${_LANG_Form_hours} %> 00 <%= ${_LANG_Form_mins} %> 00 <%= ${_LANG_Form_secs} %></span></div>
          <div class="row" id="cpu-container">
            <div class="col-xs-12 col-sm-6 col-md-3 cpu-status">
              <div class="media">
                <div class="media-left">
                  <span class="circle"></span>
                </div>
                <div class="media-body">
                  <h4 class="media-heading">cpu0:<span> 0%</span></h4>
                </div>
              </div>
            </div>
          </div>


          <div class="media">
            <div class="media-left">
              <span class="circle"></span>
            </div>
            <div class="media-body">
              <h4 class="media-heading"><%= ${_LANG_Form_Memory} %>:<span id="mem-usage">0%</span></h4>
              <p><%= ${_LANG_Form_total} %><span id="mem-total">0M</span>,<%= ${_LANG_Form_used} %><span id="mem-used">0M</span></p>
            </div>
          </div>

          <div class="media">
            <div class="media-left">
              <span class="circle"></span>
            </div>
            <div class="media-body">
              <h4 class="media-heading"><%= ${_LANG_Form_Swap} %>:<span id="swap-usage">0%</span></h4>
              <p><%= ${_LANG_Form_total} %><span id="swap-total">0M</span>,<%= ${_LANG_Form_used} %><span id="swap-used">0M</span></p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="container">
      <div class="header">
        <h1><%= ${_LANG_Form_Network_status} %></h1>
      </div>
      <div id="eths-container">

      <div class="row net-status-item">
        <div class="media col-md-4 col-sm-6">
          <div class="media-left">
            <span class="circle"></span>
          </div>
          <div class="media-body">
            <h4 class="media-heading">eth0</h4>
            <p>Loading</p>
          </div>
        </div>
        <div class="col-md-4 col-sm-6">
          <div class="row cpu-progress">
            <span class=""></span>
            <span class="cpu-progress-bar"></span>
            <div class="cpu-progress-text col-xs-offset-3 col-xs-9">----Loading----</div>
          </div>
        </div>
        <div class="col-md-4 col-sm-12">
          <div class="row">
            <div class="col-xs-6"><span class="glyphicon glyphicon-arrow-up">&nbsp;</span><span class="">0 B/s - 0 B</span></div>
            <div class="col-xs-6"><span class="glyphicon glyphicon-arrow-down">&nbsp;</span><span class="">0 B/s - 0 B</span></div>
          </div>
        </div>
      </div>

    </div>
    </div>
  </div>


<% /usr/shellgui/progs/main.sbin h_f %>

<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<%
/usr/shellgui/progs/main.sbin h_end '{"js":["/apps/status/status.js"]}'
%>
</body>

</html>
