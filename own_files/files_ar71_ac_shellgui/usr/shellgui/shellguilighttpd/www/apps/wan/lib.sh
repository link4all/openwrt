#!/bin/sh

main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "wan_pppoe" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		[ $(expr length "$FORM_username") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Username}${_LANG_Form_can_not_be_empty}"'"}' && exit 1
		[ $(expr length "$FORM_password") -gt 0 ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${FORM_password}${_LANG_Form_can_not_be_empty}"'"}' && exit 1
		if [ -n "$FORM_mtu" ]; then
		[ $(echo "$FORM_mtu" | grep -Eo '[0-9]*') = "$FORM_mtu" ]
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'MTU "${_LANG_Form_must_be_number}"'"}' && exit 1
		fi
		if [ -n "$FORM_dns1" ] || [ -n "$FORM_dns2" ]; then
		for dns in $FORM_dns1 $FORM_dns2; do
			shellgui '{"action": "check_ip", "ip": "'"${dns}"'"}' &>/dev/null
			[ $? -ne 0 ] && echo '{"status": 1, "msg": "'DNS "${_LANG_Form_must_be_IP}"'"}' && exit 1	
		done
			dns="$FORM_dns1 $FORM_dns2"
		fi
ifname=$(uci get network.${FORM_wan}.ifname)
macaddr=$(uci get network.${FORM_wan}.macaddr)
uci set network.${FORM_wan}=
uci commit network
uci set network.${FORM_wan}=interface
uci set network.${FORM_wan}.ifname="$ifname"
uci set network.${FORM_wan}.macaddr="$macaddr"

uci set network.${FORM_wan}.dns="$dns"
uci set network.${FORM_wan}.proto="pppoe"
uci set network.${FORM_wan}.username="${FORM_username}"
uci set network.${FORM_wan}.password="${FORM_password}"
uci set network.${FORM_wan}.mtu="${FORM_mtu}"
uci commit network
	cat <<EOF
{"status": 0, "msg": "[${FORM_wan}] ${_LANG_Form_Port_modify_to_mode} ${_LANG_Form_PPPOE}!"}
EOF
shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "wan_dhcp" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		if [ -n "$FORM_dns1" ] || [ -n "$FORM_dns2" ]; then
		for dns in $FORM_dns1 $FORM_dns2; do
			shellgui '{"action": "check_ip", "ip": "'"${dns}"'"}' &>/dev/null
			[ $? -ne 0 ] && echo '{"status": 1, "msg": "'DNS "${_LANG_Form_must_be_IP}"'"}' && exit 1	
		done
			dns="$FORM_dns1 $FORM_dns2"
		fi
ifname=$(uci get network.${FORM_wan}.ifname)
macaddr=$(uci get network.${FORM_wan}.macaddr)
uci set network.${FORM_wan}=
uci commit network
uci set network.${FORM_wan}=interface
uci set network.${FORM_wan}.ifname="$ifname"
uci set network.${FORM_wan}.macaddr="$macaddr"

uci set network.${FORM_wan}.dns="$dns"
uci set network.${FORM_wan}.proto="dhcp"
uci commit network
	cat <<EOF
{"status": 0, "msg": "[${FORM_wan}] ${_LANG_Form_Port_modify_to_mode} ${_LANG_Form_DHCP}!"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "wan_static" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		shellgui '{"action": "check_ip", "ip": "'"${FORM_ipaddr}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_IP_Address}${_LANG_Form_must_be_IP}"'"}' && exit 1	
		shellgui '{"action": "check_ip", "ip": "'"${FORM_netmask}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Netmask}${_LANG_Form_must_be_IP}"'"}' && exit 1	
		shellgui '{"action": "check_ip", "ip": "'"${FORM_gateway}"'"}' &>/dev/null
		[ $? -ne 0 ] && echo '{"status": 1, "msg": "'"${_LANG_Form_Gateway}${_LANG_Form_must_be_IP}"'"}' && exit 1	

		if [ -n "$FORM_dns1" ] || [ -n "$FORM_dns2" ]; then
		for dns in $FORM_dns1 $FORM_dns2; do
			shellgui '{"action": "check_ip", "ip": "'"${dns}"'"}' &>/dev/null
			[ $? -ne 0 ] && echo '{"status": 1, "msg": "'DNS "${_LANG_Form_must_be_IP}"'"}' && exit 1	
		done
			dns="$FORM_dns1 $FORM_dns2"
		fi
ifname=$(uci get network.${FORM_wan}.ifname)
macaddr=$(uci get network.${FORM_wan}.macaddr)
uci set network.${FORM_wan}=
uci commit network
uci set network.${FORM_wan}=interface
uci set network.${FORM_wan}.ifname="$ifname"
uci set network.${FORM_wan}.macaddr="$macaddr"

uci set network.${FORM_wan}.dns="$dns"
uci set network.${FORM_wan}.proto="static"
uci set network.${FORM_wan}.ipaddr="${FORM_ipaddr}"
uci set network.${FORM_wan}.netmask="${FORM_netmask}"
uci set network.${FORM_wan}.gateway="${FORM_gateway}"
uci commit network
	cat <<EOF
{"status": 0, "msg": "[${FORM_wan}] ${_LANG_Form_Port_modify_to_mode} ${_LANG_Form_Static}!"}
EOF
	shellgui '{"action": "exec_command", "cmd": "/etc/init.d/network", "arg": "restart", "is_daemon": 1, "timeout": 100000}' &>/dev/null
	exit
elif [ "${FORM_action}" = "wan_check_net" ] &>/dev/null; then

network_str=$(uci show network -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2 | grep -v '6$')
for ifce in $ifces; do
	type=;ifname=
	eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | sed 's#network\.[a-zA-Z0-9]*\.##g')
	[ -z "$type" ] && [ "$ifname" != "lo" ] && wans="$wans ${ifce}"
done

result='{}'
for wan in $wans; do
	status_str=$(ubus call network.interface.${wan} status)
	wan_ip=$(echo "$status_str" | jshon -e "ipv4-address" -e 0 -e "address" -u) && \
	mask=$(echo "$status_str" | jshon -e "ipv4-address" -e 0 -e "mask") && \
	gateway=$(echo "$status_str" | jshon -e "route" -e 0 -e "nexthop" -u) && \
	dns=$(echo "$status_str" | jshon -e "dns-server" | grep -Eo '([0-9]*\.){3}.[0-9]*' | tr '\n' ' ')
	[ "$gateway" = "0.0.0.0" ] && gateway=$(echo "$status_str" | jshon -e "route" -e 1 -e "nexthop" -u)
	eval $(ipcalc.sh ${wan_ip} ${mask})
	check_result=$(/usr/bin/wget \
	--user-agent="Mozilla/4.0 (compatible; MSIE 6.1; Windows XP)" \
	-T3 -t 0 \
	--bind-address=${ip} \
	-qO- "http://pv.sohu.com/cityjson?ie=utf-8" 2>/dev/null | awk -F "returnCitySN =" '{print $2}' | sed 's#};#}#g')
	if echo "$check_result" | jshon -t &>/dev/null; then
	result=$(echo "$result" | jshon -n {} -i "${wan}" -e "${wan}" \
	-n 0 -i "status" \
	-s "${wan_ip}" -i "ip" \
	-s "${NETMASK}" -i "mask" \
	-s "${gateway}" -i "gateway" \
	-s "${dns}" -i "dns" -p -j)
	else
	result=$(echo "$result" | jshon -n {} -i "${wan}" -e "${wan}" \
	-n 1 -i "status" -p -j)
	fi
done
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$result"
	exit
fi
}
