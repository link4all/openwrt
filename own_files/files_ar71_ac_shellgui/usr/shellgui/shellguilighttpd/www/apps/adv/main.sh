#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
    if [ "${GET_action}" = "switch_status" ] &>/dev/null; then
	# action: switch_status 修改UPnP 启用禁用
		if [ ${FORM_switch} -eq 1 ]; then
		# 然后去处理switch 处理完成后返回处理结果——code || FORM_switch=0
			/etc/init.d/miniupnpd enable &>/dev/null
			/etc/init.d/miniupnpd restart &>/dev/null
		else
			/etc/init.d/miniupnpd disable &>/dev/null
			/etc/init.d/miniupnpd stop &>/dev/null
		fi
		result=$?
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        cat <<EOF
{"code": $?}
EOF
        exit
    elif [ "${GET_action}" = "upnp_config" ] &>/dev/null; then
	# action: upnp_config 查询upnp是否启用开关
		ls /etc/rc.d/ | grep -qE 'S[0-9]*miniupnpd$' && upnp_statys=1 || upnp_statys=0
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        cat <<EOF
{"code": 0, "switch_status": $upnp_statys,"list": $(shellgui '{"action": "miniupnp_list"}')}
EOF
    exit
    elif [ "${FORM_action}" = "dhcp_query" ] &>/dev/null; then
	# action: dhcp_query 获取静态IP绑定列表
		dhcp_str=$(uci show dhcp -X)
		configs=$(echo "$dhcp_str" | grep '=host$' | cut -d '=' -f1 | cut -d '.' -f2)
		if [ -z "$configs" ]; then
			printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
			cat <<EOF
{"list": [], "code": 0 }
EOF
			exit
		else
			result='{"list": [], "code": 0}'
			for config in $configs; do
				eval $(echo "$dhcp_str" | grep "dhcp\.${config}\." | cut -b 16-)
				result=$(echo "$result" | jshon -e "list" \
				-n {} -i append -e -1 \
				-s $ip -i ip \
				-s $mac -i mac \
				-s $name -i dname \
				-s $config -i tag \
				-p -p -j)
			done
			printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
			echo "$result"
			exit
		fi
    elif [ "${FORM_action}" = "get_ddns_list" ] &>/dev/null; then
	# action: get_ddns_list 获取 ddns 全部记录
		ddns_str=$(uci show ddns -X | grep -vE '^ddns.myddns_ipv[4|6]')
		configs=$(echo "$ddns_str" | grep '=service$' | cut -d '=' -f1 | cut -d '.' -f2)
		result='{"list": [], "code": 0}'
			for config in $configs; do
				date_last_update=$(grep 'info :' /var/log/ddns/${config}.log | tail -n 1 | awk -F 'at ' '{print $2}')
				last_update=$(date -d "$date_last_update" +%s)
				[ -z "$last_update" ] && last_update=0
				eval $(echo "$ddns_str" | grep "ddns\.${config}\." | sed "s#ddns\.[a-zA-Z0-9_]*\.##g")
				result=$(echo "$result" | jshon -e "list" \
				-n {} -i append -e -1 \
				-s "$service_name" -i servicename \
				-s "$domain" -i domain \
				-n $enabled -i "enabled" \
				-n $last_update -i "lastupdate" \
				-s "$config" -i "config" \
				-p -p -j)
			done
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        echo "$result"
    exit
    elif [ "${FORM_action}" = "ddns_switch" ] &>/dev/null; then
	# action: ddns_switch 禁用一条ddns记录
	uci set ddns.${FORM_config}.enabled=${FORM_enabled}
	uci commit ddns
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        cat <<EOF
{"code":0}
EOF
    exit     
    elif [ "${FORM_action}" = "edit_ddns" ] &>/dev/null; then
	# action: edit_ddns 打开 ddns 单条编辑
	eval $(uci show ddns.${FORM_config} | grep -v '=service$'| sed "s#ddns\.[a-zA-Z0-9_]*\.##g")
	[ -z "$force_interval" ] && force_interval=0
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        cat <<EOF
{"servicename": "$service_name", "username":"$username","force_interval":$force_interval,"code":0,"enabled":0,"domain":"$domain","check_interval":$check_interval,"password":"$password"}
EOF
    exit    
    elif [ "${FORM_action}" = "get_portforward_list" ] &>/dev/null; then
	# action: get_portforward_list 获取端口转发列表
	firewall_str=$(uci show firewall -X)
	configs=$(echo "$firewall_str" | grep '=redirect$' | cut -d '=' -f1 | cut -d '.' -f2)
	result='{"list": [], "code": 0}'
		for config in $configs; do
			src_dport=;name=
			eval $(echo "$firewall_str" | grep "firewall\.${config}\." | sed "s#firewall\.[a-zA-Z0-9_]*\.##g")
			[ $src_dport -gt 0 ] &>/dev/null || continue
			[ $dest_port -gt 0 ] &>/dev/null || continue
			[ -z "$src_dport" ] && continue
				result=$(echo "$result" | jshon -e "list" \
				-n {} -i append -e -1 \
				-s "$config" -i "config" \
				-s "$name" -i "name" \
				-s "$(echo $proto | tr ' ' '+')" -i "proto" \
				-n $src_dport -i "src_dport" \
				-s "$dest_ip" -i "dest_ip" \
				-n $dest_port -i "dest_port" \
				-p -p -j)
		done

        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        echo "$result"
		exit
    elif [ "${FORM_action}" = "get_a_portforward" ] &>/dev/null; then
	# action: get_a_portforward 获取单条端口转发记录
		eval $(uci show firewall -X | grep "firewall\.${FORM_config}\." | sed "s#firewall\.[a-zA-Z0-9_]*\.##g")
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        cat <<EOF
{"item": {"config": "${FORM_config}", "name": "$name", "proto": "$(echo $proto | tr ' ' '+')", "src_dport": $src_dport, "dest_ip": "$dest_ip", "dest_port": $dest_port}, "code": 0}
EOF
    exit
    elif [ "${FORM_action}" = "get_rangeforward_list" ] &>/dev/null; then
	# action: get_rangeforward_list 获取范围端口转发记录
	firewall_str=$(uci show firewall -X)
	configs=$(echo "$firewall_str" | grep '=redirect$' | cut -d '=' -f1 | cut -d '.' -f2)
	result='{"list": [], "code": 0}'
		for config in $configs; do
			src_dport=;name=
			eval $(echo "$firewall_str" | grep "firewall\.${config}\." | sed "s#firewall\.[a-zA-Z0-9_]*\.##g")
			[ $src_dport -gt 0 ] &>/dev/null && continue
			[ -z "$src_dport" ] && continue
		start_port=$(echo $src_dport | cut -d '-' -f1)
		end_port=$(echo $src_dport | cut -d '-' -f2)
				result=$(echo "$result" | jshon -e "list" \
				-n {} -i append -e -1 \
				-s "$config" -i "config" \
				-s "$name" -i "name" \
				-s "$(echo $proto | tr ' ' '+')" -i "proto" \
				-s "$start_port" -i "start_port" \
				-s "$dest_ip" -i "dest_ip" \
				-s "$end_port" -i "end_port" \
				-p -p -j)
		done

        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		echo "$result"
		exit
    elif [ "${FORM_action}" = "get_a_rangeforward" ] &>/dev/null; then
	# action: get_rangeforward_list 获取单条范围端口转发记录
		eval $(uci show firewall -X | grep "firewall\.${FORM_config}\." | sed "s#firewall\.[a-zA-Z0-9_]*\.##g")
		start_port=$(echo $src_dport | cut -d '-' -f1)
		end_port=$(echo $src_dport | cut -d '-' -f2)
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        cat <<EOF
{"code":0, "item":{"config": "${FORM_config}", "name": "$name", "proto": "$(echo $proto | tr ' ' '+')", "start_port": "$start_port", "end_port": "$end_port", "dest_ip": "$dest_ip"}}
EOF
    exit
    elif [ "${FORM_action}" = "get_dmzStatus" ] &>/dev/null; then
	# action: get_dmzStatus 获取 DMZ 记录
		firewall_str=$(uci show firewall -X)
		configs=$(echo "$firewall_str" | grep '=redirect$' | cut -d '=' -f1 | cut -d '.' -f2)
		for config in $configs; do
			src_dport=;name=
			eval $(echo "$firewall_str" | grep "firewall\.${config}\." | sed "s#firewall\.[a-zA-Z0-9_]*\.##g")
			[ -z "$src_dport" ] && [ -n "$dest_ip" ] && dmz_ip="$dest_ip" && break
		done
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		if [ -n "$dmz_ip" ] && [ $enabled -gt 0 ]; then
			cat <<EOF
{"code":0, "switch_status": 1, "ip": "$dmz_ip"}
EOF
		else
			cat <<EOF
{"status":0, "switch_status": 0, "ip": "192.168.1.100"}
EOF
		fi
    exit
    fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf %>
<% /usr/shellgui/progs/main.sbin h_nav '{"active": "adv"}' %>
</div>

<div id="main">
    <div class="container">
      <div class="header">
        <h1><%= ${_LANG_Form_UPnP_protocol} %></h1>
        <div class="switch-ctrl">
          <input type="checkbox" name="" id="upnp_switch" checked disabled>
          <label for="upnp_switch"><span></span></label>
        </div>
        <span id="open_upnp_text" class="hidden upnp_text">&nbsp;&nbsp;&nbsp;&nbsp;正在开启。。。</span>
        <span id="close_upnp_text" class="hidden upnp_text">&nbsp;&nbsp;&nbsp;&nbsp;正在关闭。。。</span>
      </div>
      <div class="content table-responsive">
        <table class="table">
          <caption id="upnp_dev_list_title"><%= ${_LANG_Form_UPnP_device_list} %></caption>
          <thead id="upnp_dev_list_header">
            <tr>
              <th><%= ${_LANG_Form_Proto} %></th>
              <th><%= ${_LANG_Form_Application} %></th>
              <th><%= ${_LANG_Form_Client_IP} %></th>
              <th><%= ${_LANG_Form_InternalPort} %></th>
              <th><%= ${_LANG_Form_ExternalPort} %></th>
            </tr>
          </thead>
          <tbody id="upnp_dev_list" class="hidden"></tbody>
          <tfoot>
            <tr>
              <td colspan="5" class="text-center">
                <span id="none_upnp_text"><%= ${_LANG_Form_None_UPnP_device} %></span>
                <span id="disabled_upnp_text" class="hidden"><%= ${_LANG_Form_UPnP_disabled} %></span>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>

    <div class="container">
      <div class="header">
        <h1 class=""><%= ${_LANG_Form_DHCP_static_IP} %></h1>
      </div>
      <div class="content table-responsive">
        <table class="table">
          <caption id="dhcp_ip_list_title"><%= ${_LANG_Form_Combined_devices} %></caption>
          <thead id="dhcp_ip_list_header">
            <tr>
              <th><%= ${_LANG_Form_Device} %></th>
              <th><%= ${_LANG_Form_IP_Address} %></th>
              <th><%= ${_LANG_Form_MAC_Address} %></th>
              <th><%= ${_LANG_Form_Option} %></th>
            </tr>
          </thead>
          <tbody id="dhcp_ip_list" class="hidden"></tbody>
          <tfoot>
            <tr>
              <td colspan="5" class="text-center" id="none_dhcp_text"><%= ${_LANG_Form_None_DHCP_static_IP_device} %></td>
            </tr>
          </tfoot>
        </table>
      </div>
      <button type="button" class="btn btn-default" data-toggle="modal" data-target="#dhcpModal"><%= ${_LANG_Form_Add_new} %></button>
    </div>

    <div class="container">
      <div class="header">
        <h1 class=""><%= ${_LANG_Form_DDNS} %></h1>
      </div>
      <div class="content table-responsive">
        <table class="table">
          <caption id="ddns_rec_list_title"><%= ${_LANG_Form_DDNS_list} %></caption>
          <thead id="ddns_rec_list_header">
            <tr>
              <th><%= ${_LANG_Form_Domain} %></th>
              <th><%= ${_LANG_Form_Last_update} %></th>
              <th><%= ${_LANG_Form_Status} %></th>
              <th><%= ${_LANG_Form_Option} %></th>
            </tr>
          </thead>
          <tbody id="ddns_rec_list" class="hidden"></tbody>
          <tfoot>
            <tr>
              <td colspan="5" class="text-center" id="none_ddns_text"><%= ${_LANG_Form_None_DDNS_record} %></td>
            </tr>
          </tfoot>
        </table>
      </div>
      <button type="button" class="btn btn-default" id="add_ddns_rec_btn" data-toggle="modal" data-target="#ddnsModal"><%= ${_LANG_Form_Add_new} %></button>
    </div>

    <div class="container">
      <div class="header">
        <h1 class=""><%= ${_LANG_Form_Port_forward} %></h1>
      </div>
      <div class="content">
        <div class="table-responsive">
          <table class="table">
            <caption id="port_forward_list_title"><%= ${_LANG_Form_Port_forward_list} %></caption>
            <thead id="port_forward_list_header">
              <tr>
                <th><%= ${_LANG_Form_record} %></th>
                <th><%= ${_LANG_Form_Proto} %></th>
                <th><%= ${_LANG_Form_ExternalPort} %></th>
                <th><%= ${_LANG_Form_Internal_IP_address} %></th>
                <th><%= ${_LANG_Form_InternalPort} %></th>
                <th><%= ${_LANG_Form_Option} %></th>
              </tr>
            </thead>
            <tbody id="port_forward_list" class="hidden"></tbody>
            <tfoot>
              <tr>
                <td colspan="5" class="text-center" id="none_portfw_text"><%= ${_LANG_Form_None_Port_forward_record} %></td>
              </tr>
            </tfoot>
          </table>
        </div>
        <button type="button" id="add_portfw_btn" class="btn btn-default" data-toggle="modal" data-target="#portForwardingModal"><%= ${_LANG_Form_Add_new} %></button>
        <div class="table-responsive">
          <table class="table">
            <caption id="range_forward_list_title"><%= ${_LANG_Form_Ports_forward_list} %></caption>
            <thead id="range_forward_list_header">
              <tr>
                <th><%= ${_LANG_Form_record} %></th>
                <th><%= ${_LANG_Form_Proto} %></th>
                <th><%= ${_LANG_Form_Start_port} %></th>
                <th><%= ${_LANG_Form_End_port} %></th>
                <th><%= ${_LANG_Form_Internal_IP_address} %></th>
                <th><%= ${_LANG_Form_Option} %></th>
              </tr>
            </thead>
            <tbody id="range_forward_list" class="hidden"></tbody>
            <tfoot>
              <tr>
                <td colspan="5" class="text-center" id="none_rangefw_text"><%= ${_LANG_Form_None_Ports_forward_record} %></td>
              </tr>
            </tfoot>
          </table>
        </div>
        <button type="button" id="add_rangefw_btn" class="btn btn-default" data-toggle="modal" data-target="#rangeForwardingModal"><%= ${_LANG_Form_Add_new} %></button>
      </div>
    </div>

    <div class="container">
      <div class="header">
        <h1>DMZ</h1>
        <div class="switch-ctrl">
          <input type="checkbox" id="dmz_switch">
          <label for="dmz_switch"><span></span></label>
        </div>
      </div>
      <div class="content">
        <span class="text-center" id="dmz_help_text"><%= ${_LANG_Form_DMZ_help} %></span>
        <div class="row disabled hidden" id="dmz_form_container">
          <div class="col-sm-6">
            <form class="form-horizontal" id="dmz_form">
              <div class="form-group">
                <label for="dmz_ip" class="col-sm-3 control-label"><%= ${_LANG_Form_IP_Address} %></label>
                <div class="col-sm-9">
                  <input type="text" class="form-control" name="ip" id="dmz_ip" value='' required>
                </div>
              </div>
              <div class="form-group">
                <label for="netmask" class="col-sm-3 control-label"><%= ${_LANG_Form_DMZ_status} %></label>
                <div class="col-sm-9">
                  <span class="form-control dmz-status" id="dmz_status_text"><%= ${_LANG_Form_Uneffected} %></span>
                </div>
              </div>

              <div class="form-group">
                <div class="col-sm-offset-3 col-sm-9">
                  <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>


<!-- DHCP的静态IP分配 弹窗 -->
  <div class="modal fade" id="dhcpModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h4 class="modal-title" id="dhcpModalLabel">绑定设备</h4>
        </div>
        <div class="modal-body">
          <form class="form" id="add_dhcp_form">
            <div class="form-group">
              <label for="dev-name" class="control-label"><%= ${_LANG_Form_Device} %>:</label>
              <input type="text" class="form-control" id="dev-name" name="dname">
            </div>
            <div class="form-group">
              <label for="ip-addr" class="control-label"><%= ${_LANG_Form_IP_Address} %>:</label>
              <input type="text" class="form-control" id="ip-addr" name="ip">
            </div>
            <div class="form-group">
              <label for="mac-addr" class="control-label"><%= ${_LANG_Form_MAC_Address} %>:</label>
              <input type="text" class="form-control" id="mac-addr" name="mac">
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary" id="add_dhcp_btn" data-dismiss="modal"><%= ${_LANG_Form_Confirm} %></button>
          <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
        </div>
      </div>
    </div>
  </div>

  <!-- 动态域名解析 弹窗 -->
  <div class="modal fade" id="ddnsModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h4 class="modal-title" id="ddnsModalLabel"><%= ${_LANG_Form_Add_DDNS_record} %></h4>
        </div>
        <div class="modal-body">
          <form class="form" id="add_ddns_form">
            <div class="form-group">
              <label for="service_name" class="control-label"><%= ${_LANG_Form_Service_providers} %>:</label>
              <select type="text" class="form-control" id="service_name" name="service_name">
<%
list_str=$(grep -v "#" /usr/lib/ddns/services | sed "/^$/d" | tr -d "\"" | while read  service_name url ; do echo ${service_name} ; done)
echo "$list_str" | while read domain_mgr; do
cat <<EOF
<option value="${domain_mgr}" > ${domain_mgr} </option>
EOF
done
%>
              </select>
            </div>
            <div class="form-group">
              <label for="ddns-username" class="control-label"><%= ${_LANG_Form_Username} %>:</label>
              <input type="text" class="form-control" id="ddns-username" name="username">
            </div>
            <div class="form-group">
              <label for="ddns-pwd" class="control-label"><%= ${_LANG_Form_Password} %>:</label>
              <input type="password" class="form-control" id="ddns-pwd" name="password">
            </div>
            <div class="form-group">
              <label for="ddns-host" class="control-label"><%= ${_LANG_Form_Domain} %>:</label>
              <input type="text" class="form-control" id="ddns-host" name="domain">
            </div>
            <div class="form-group">
              <label for="ddns-check-interval" class="control-label"><%= ${_LANG_Form_Check_interval} %>:</label>
              <div class="input-group">
              <input type="text" class="form-control" id="ddns-check-interval" name="check_interval" value="10">
              <div class="input-group-addon"><%= ${_LANG_Form_Minutes} %></div>
              </div>
            </div>
            <div class="form-group">
              <label for="ddns-force-update" class="control-label"><%= ${_LANG_Form_Forced_update} %>:</label>
              <div class="input-group">
                <input type="text" class="form-control" id="ddns-force-update" name="force_interval" value="0">
                <div class="input-group-addon"><%= ${_LANG_Form_Hours} %></div>
              </div>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary" id="submit_ddns_btn" data-submit-target='add' data-dismiss="modal"><%= ${_LANG_Form_Confirm} %></button>
          <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
        </div>
      </div>
    </div>
  </div>

  <!-- 端口转发 弹窗 -->
  <div class="modal fade" id="portForwardingModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h4 class="modal-title" id="portForwardingModalLabel"><%= ${_LANG_Form_Port_forward} %></h4>
        </div>
        <div class="modal-body">
          <form class="form" id="add_portfw_form">
            <div class="form-group">
              <label for="port-fwd-name" class="control-label"><%= ${_LANG_Form_record} %>:</label>
              <input type="text" class="form-control" id="port-fwd-name" name="name">
            </div>
            <div class="form-group">
              <label for="port-fwd-protocol" class="control-label"><%= ${_LANG_Form_Proto} %>:</label>
              <select class="form-control" id="port-fwd-protocol" name="proto">
                <option value='tcp'>tcp</option>
                <option value='udp'>udp</option>
                <option value='tcp+udp'>tcp+udp</option>
              </select>
            </div>
            <div class="form-group">
              <label for="outer-port" class="control-label"><%= ${_LANG_Form_ExternalPort} %>:</label>
              <input type="text" class="form-control" id="outer-port" name="src_dport">
            </div>
            <div class="form-group">
              <label for="inner-ip-addr" class="control-label"><%= ${_LANG_Form_Internal_IP_address} %>:</label>
              <input type="text" class="form-control" id="inner-ip-addr" name="dest_ip">
            </div>
            <div class="form-group">
              <label for="inner-port" class="control-label"><%= ${_LANG_Form_InternalPort} %>:</label>
              <input type="text" class="form-control" id="inner-port" name="dest_port">
            </div>
            <input type="hidden" value='' name="config" id="portfw_config">
          </form>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary" id="submit_portfw_btn" data-submit-target='add' data-dismiss="modal"><%= ${_LANG_Form_Confirm} %></button>
          <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
        </div>
      </div>
    </div>
  </div>

  <!-- 范围转发 弹窗 -->
  <div class="modal fade" id="rangeForwardingModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h4 class="modal-title" id="rangeForwardingModalLabel"><%= ${_LANG_Form_Ports_forward} %></h4>
        </div>
        <div class="modal-body">
          <form class="form" id="add_rangefw_form">
            <div class="form-group">
              <label for="range-fwd-name" class="control-label"><%= ${_LANG_Form_record} %>:</label>
              <input type="text" class="form-control" id="range-fwd-name" name="name">
            </div>
            <div class="form-group">
              <label for="range-fwd-protocol" class="control-label"><%= ${_LANG_Form_Proto} %>:</label>
              <select class="form-control" id="range-fwd-protocol" name="proto">
                <option value="tcp">tcp</option>
                <option value="udp">udp</option>
                <option value="tcp+udp">tcp+udp</option>
              </select>
            </div>
            <div class="form-group">
              <label for="start-port" class="control-label"><%= ${_LANG_Form_Start_port} %>:</label>
              <input type="text" class="form-control" id="start-port" name="start_port">
            </div>
            <div class="form-group">
              <label for="end-port" class="control-label"><%= ${_LANG_Form_End_port} %>:</label>
              <input type="text" class="form-control" id="end-port" name="end_port">
            </div>
            <div class="form-group">
              <label for="range-fwd-inner-ip-addr" class="control-label"><%= ${_LANG_Form_Internal_IP_address} %>:</label>
              <input type="text" class="form-control" id="range-fwd-inner-ip-addr" name="dest_ip">
            </div>
            <input type="hidden" value='' name="config" id="rangefw_config">
          </form>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary" id="submit_rangefw_btn" data-submit-target='add' data-dismiss="modal"><%= ${_LANG_Form_Confirm} %></button>
          <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
        </div>
      </div>
    </div>
  </div>


  <!-- 确认 弹窗 -->
  <div class="modal fade" id="confirmModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h4 class="modal-title" id="confirm_title"></h4>
        </div>
        <div class="modal-body">
          <h5 id="confirm_text"></h5>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary" id="confirm_submit" data-dismiss="modal"><%= ${_LANG_Form_Confirm} %></button>
          <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
        </div>
      </div>
    </div>
  </div>

<% /usr/shellgui/progs/main.sbin h_f%>
<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<% /usr/shellgui/progs/main.sbin h_end '{"js":["/apps/adv/adv.js"]}'
%>
</body>
</html>