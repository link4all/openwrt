#!/bin/sh

main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "dhcp_combine" ] &>/dev/null; then
# action: dhcp_combine 绑定一条静态地址绑定
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "${FORM_dname}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Device}${_LANG_Form_can_not_be_empty}"'"}' && exit 1	
		shellgui '{"action": "check_ip", "ip": "'"${FORM_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_IP_Address}${_LANG_Form_must_be_IP}"'"}' && exit 1	
		shellgui '{"action": "check_mac", "mac": "'"${FORM_mac}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_MAC_Address}${_LANG_Form_must_be_MAC}"'"}' && exit 1
cfg=$(uci add dhcp host)
uci set dhcp.$cfg=host
uci set dhcp.$cfg.name="${FORM_dname}"
uci set dhcp.$cfg.ip=${FORM_ip}
uci set dhcp.$cfg.mac=${FORM_mac}
uci commit dhcp

	cat <<EOF
{"status": 0, "msg": "${FORM_dname} ${_LANG_Form_Combined_You_need_to_restart_the_device}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/dnsmasq", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "dhcp_uncombine" ] &>/dev/null; then
# action: dhcp_uncombine 解绑一条静态地址绑定
	uci set dhcp.${FORM_tag}=
	uci commit dhcp
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Uncombined}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/dnsmasq", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "add_ddns" ] &>/dev/null; then
# action: add_ddns 添加一条 ddns 记录
	for key in domain username password; do
		if [ -z "$(eval echo '$FORM_'${key})" ]; then
			printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
			cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Parameter_incomplete}"}
EOF
			exit
		fi
	done
	[ ${FORM_force_interval} -gt 0 ] || FORM_force_interval=0
	[ ${FORM_check_interval} -gt 0 ] || FORM_check_interval=0
	config=$(echo "${FORM_domain}" | sed -e 's/\./_/g' -e 's/-/_/g')

	uci set ddns.${config}="service"
	uci set ddns.${config}.service_name="${FORM_service_name}"
	uci set ddns.${config}.domain="${FORM_domain}"
	uci set ddns.${config}.username="${FORM_username}"
	uci set ddns.${config}.password="${FORM_password}"
	uci set ddns.${config}.ip_source='web'
	uci set ddns.${config}.ip_network='wan'
	uci set ddns.${config}.enabled=1
	uci set ddns.${config}.check_interval="${FORM_check_interval}"
	uci set ddns.${config}.check_unit='minutes'
	uci set ddns.${config}.force_interval=${FORM_force_interval}
	uci commit ddns
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_ddns_record} ${FORM_domain} ${_LANG_Form_successfull_added}"}
EOF
	(/usr/lib/ddns/dynamic_dns_updater.sh ${config} &>/dev/null) &
	exit
elif [ "${FORM_action}" = "edit_a_ddns" ] &>/dev/null; then
# action: edit_a_ddns 编辑一条 ddns 记录
	for key in domain username password; do
		if [ -z "$(eval echo '$FORM_'${key})" ]; then
			printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
			cat <<EOF
{"status": 1, "msg": "${_LANG_Form_Parameter_incomplete}"}
EOF
			exit
		fi
	done
	[ ${FORM_force_interval} -gt 0 ] || FORM_force_interval=0
	[ ${FORM_check_interval} -gt 0 ] || FORM_check_interval=0

	config=$(echo "${FORM_domain}" | sed -e 's/\./_/g' -e 's/-/_/g')
	uci set ddns.${config}.service_name="${FORM_service_name}"
	uci set ddns.${config}.domain="${FORM_domain}"
	uci set ddns.${config}.username="${FORM_username}"
	uci set ddns.${config}.password="${FORM_password}"
	uci set ddns.${config}.ip_source='web'
	uci set ddns.${config}.ip_network='wan'
	uci set ddns.${config}.enabled=1
	uci set ddns.${config}.check_interval="${FORM_check_interval}"
	uci set ddns.${config}.check_unit='minutes'
	uci set ddns.${config}.force_interval=${FORM_force_interval}
	uci commit ddns
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_ddns_record}${_LANG_Form_successfull_edited}"}
EOF
	(/usr/lib/ddns/dynamic_dns_updater.sh ${config} &>/dev/null) &
	exit
elif [ "${FORM_action}" = "del_a_ddns" ] &>/dev/null; then
# action: del_a_ddns 删除一条ddns记录
	uci set ddns.${FORM_config}=
	uci commit ddns
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_ddns_record}${_LANG_Form_successfull_deled}"}
EOF
	exit
elif [ "${FORM_action}" = "update_ddns" ] &>/dev/null; then
# action: update_ddns 更新单条 ddns 记录
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_record_updated_time_will_flash_later}"}
EOF
	(/usr/lib/ddns/dynamic_dns_updater.sh ${FORM_config} &>/dev/null) &
	exit
elif [ "${FORM_action}" = "edit_portforward" ] &>/dev/null; then
# action: edit_portforward 更新单条 端口转发 记录
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ -z "${FORM_config}" ] && echo '{"status": 0, "msg": "Err"}' && exit
		[ $(expr length "${FORM_name}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_record}${_LANG_Form_can_not_be_empty}"'"}' && exit 1
		[ $(echo "$FORM_src_dport" | grep -Eo '[0-9]*') = "$FORM_src_dport" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_ExternalPort}${_LANG_Form_must_be_number}"'"}' && exit 1
		shellgui '{"action": "check_ip", "ip": "'"${FORM_dest_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Client_IP}${_LANG_Form_must_be_IP}"'"}' && exit 1
		[ $(echo "$FORM_dest_port" | grep -Eo '[0-9]*') = "$FORM_dest_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_InternalPort}${_LANG_Form_must_be_number}"'"}' && exit 1
uci set firewall.${FORM_config}.target='DNAT'
uci set firewall.${FORM_config}.src='wan'
uci set firewall.${FORM_config}.dest='lan'
uci set firewall.${FORM_config}.proto="$(echo ${FORM_proto} | tr '+' ' ')"
uci set firewall.${FORM_config}.src_dport="${FORM_src_dport}"
uci set firewall.${FORM_config}.dest_ip="${FORM_dest_ip}"
uci set firewall.${FORM_config}.dest_port="${FORM_dest_port}"
uci set firewall.${FORM_config}.name="${FORM_name}"
uci set firewall.${FORM_config}.enabled='1'
uci commit firewall
	# printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Port_forward_record}${_LANG_Form_successfull_edited}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "new_portforward" ] &>/dev/null; then
# action: new_portforward 添加一条端口转发记录
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "${FORM_name}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_record}${_LANG_Form_can_not_be_empty}"'"}' && exit 1
		[ $(echo "$FORM_src_dport" | grep -Eo '[0-9]*') = "$FORM_src_dport" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_ExternalPort}${_LANG_Form_must_be_number}"'"}' && exit 1
		shellgui '{"action": "check_ip", "ip": "'"${FORM_dest_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Client_IP}${_LANG_Form_must_be_IP}"'"}' && exit 1
		[ $(echo "$FORM_dest_port" | grep -Eo '[0-9]*') = "$FORM_dest_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_InternalPort}${_LANG_Form_must_be_number}"'"}' && exit 1
FORM_config=$(uci add firewall redirect)
uci set firewall.${FORM_config}.target='DNAT'
uci set firewall.${FORM_config}.src='wan'
uci set firewall.${FORM_config}.dest='lan'
uci set firewall.${FORM_config}.proto="$(echo ${FORM_proto} | tr '+' ' ')"
uci set firewall.${FORM_config}.src_dport="${FORM_src_dport}"
uci set firewall.${FORM_config}.dest_ip="${FORM_dest_ip}"
uci set firewall.${FORM_config}.dest_port="${FORM_dest_port}"
uci set firewall.${FORM_config}.name="${FORM_name}"
uci set firewall.${FORM_config}.enabled='1'
uci commit firewall
	# printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Port_forward_record}${_LANG_Form_successfull_added}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "del_a_portforward" ] &>/dev/null; then
# action: del_a_portforward 删除一条端口转发记录
	uci set firewall.${FORM_config}=
	uci set firewall
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Port_forward_record}${_LANG_Form_successfull_deled}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "new_rangeforward" ] &>/dev/null; then
# action: new_rangeforward 添加新的范围端口转发
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "${FORM_name}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_record}${_LANG_Form_can_not_be_empty}"'"}' && exit 1
		[ $(echo "$FORM_start_port" | grep -Eo '[0-9]*') = "$FORM_start_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Start_port}${_LANG_Form_must_be_number}"'"}' && exit 1
		[ $(echo "$FORM_end_port" | grep -Eo '[0-9]*') = "$FORM_end_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_End_port}${_LANG_Form_must_be_number}"'"}' && exit 1
		shellgui '{"action": "check_ip", "ip": "'"${FORM_dest_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Client_IP}${_LANG_Form_must_be_IP}"'"}' && exit 1
FORM_config=$(uci add firewall redirect)
uci set firewall.${FORM_config}.target='DNAT'
uci set firewall.${FORM_config}.src='wan'
uci set firewall.${FORM_config}.dest='lan'
uci set firewall.${FORM_config}.proto="$(echo ${FORM_proto} | tr '+' ' ')"
uci set firewall.${FORM_config}.src_dport="${FORM_start_port}-${FORM_end_port}"
uci set firewall.${FORM_config}.dest_ip="${FORM_dest_ip}"
uci set firewall.${FORM_config}.dest_port="${FORM_start_port}-${FORM_end_port}"
uci set firewall.${FORM_config}.name="${FORM_name}"
uci set firewall.${FORM_config}.enabled='1'
uci commit firewall
	# printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Ports_forward_record}${_LANG_Form_successfull_added}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "del_a_rangeforward" ] &>/dev/null; then
# action: del_a_rangeforward 删除一个范围端口映射
	uci set firewall.${FORM_config}=
	uci set firewall
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Ports_forward_record}${_LANG_Form_successfull_deled}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "edit_rangeforward" ] &>/dev/null; then
# action: edit_rangeforward 修改范围端口转发
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "${FORM_name}") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_record}${_LANG_Form_can_not_be_empty}"'"}' && exit 1
		[ $(echo "$FORM_start_port" | grep -Eo '[0-9]*') = "$FORM_start_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Start_port}${_LANG_Form_must_be_number}"'"}' && exit 1
		[ $(echo "$FORM_end_port" | grep -Eo '[0-9]*') = "$FORM_end_port" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_End_port}${_LANG_Form_must_be_number}"'"}' && exit 1
		shellgui '{"action": "check_ip", "ip": "'"${FORM_dest_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Client_IP}${_LANG_Form_must_be_IP}"'"}' && exit 1
port_range="${FORM_start_port}-${FORM_end_port}"
uci set firewall.${FORM_config}.target='DNAT'
uci set firewall.${FORM_config}.src='wan'
uci set firewall.${FORM_config}.dest='lan'
uci set firewall.${FORM_config}.proto="$(echo ${FORM_proto} | tr '+' ' ')"
uci set firewall.${FORM_config}.src_dport="${port_range}"
uci set firewall.${FORM_config}.dest_ip="${FORM_dest_ip}"
uci set firewall.${FORM_config}.dest_port="$port_range"
uci set firewall.${FORM_config}.name="${FORM_name}"
uci set firewall.${FORM_config}.enabled='1'
uci commit firewall

	# printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Ports_forward_record}${_LANG_Form_successfull_edited}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "change_dmzStatus" ] &>/dev/null; then
# action: change_dmzStatus 关闭端口映射
	firewall_str=$(uci show firewall -X)
	echo "$firewall_str" | grep 'proto=.*all' | cut -d '.' -f2 | while read config; do
	uci set firewall.${config}.enabled=0
	done
	uci commit firewall
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "DMZ ${_LANG_Form_Uneffected}"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "save_dmzStatus" ] &>/dev/null; then
# action: save_dmzStatus 变更 DMZ 设置(开启)
	firewall_str=$(uci show firewall -X)
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		shellgui '{"action": "check_ip", "ip": "'"${FORM_ip}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"code": 1, "status": 1, "msg": "'"${_LANG_Form_Internal_IP_address_wrong}"'"}' && exit 1
	echo "$firewall_str" | grep 'proto=.*all' | cut -d '.' -f2 | while read config; do
	uci set firewall."${config}"=''
	done
		
config=$(uci add firewall redirect)
uci set firewall.${config}=redirect
uci set firewall.${config}.src='wan'
uci set firewall.${config}.proto='all'
uci set firewall.${config}.dest_ip="$FORM_ip"
uci set firewall.${config}.enabled='1'
uci commit firewall
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_DMZ_take_effect_in} IP: $FORM_ip"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/firewall", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit					
fi
}