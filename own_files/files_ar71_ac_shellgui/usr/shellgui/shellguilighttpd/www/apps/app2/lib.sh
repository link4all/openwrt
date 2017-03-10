#!/bin/sh

main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
if
[ "${FORM_action}" = "set_pppoe" ] &>/dev/null
then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${FORM_dev} set_pppoe成功!"}
EOF
	exit
elif
[ "${FORM_action}" = "wan_pppoe" ] &>/dev/null
then
# FORM_app=wan
# FORM_wan=wan
# FORM_action=wan_pppoe
# FORM_dns1=44
# FORM_dns2=55
# FORM_pppoePwd=22
# FORM_mtu=33
# FORM_session=2e821f774d81
# FORM_pppoeName=11

	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "Wan口已成功设置为pppoe!"}
EOF
	exit
elif
[ "${FORM_action}" = "wan_dhcp" ] &>/dev/null
then
# FORM_app=wan
# FORM_wan=wan
# FORM_action=wan_dhcp
# FORM_dns1=1
# FORM_dns2=2
# FORM_session=7c957600f950

	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "Wan口已成功设置为dhcp!"}
EOF
	exit
elif
[ "${FORM_action}" = "wan_static" ] &>/dev/null
then
# FORM_staticGateway=33
# FORM_app=wan
# FORM_staticIp=11
# FORM_wan=wan
# FORM_action=wan_static
# FORM_dns1=44
# FORM_dns2=55
# FORM_staticMask=22
# FORM_session=7c957600f950

	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "Wan口已成功设置为static!"}
EOF
	exit
elif
[ "${FORM_action}" = "wan_check_net" ] &>/dev/null
then

	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"code":0,"list":[{"wan":"wan","status":0},{"wan":"wan2","status":1},{"wan":"wan3","status":0}]}
EOF
	exit
fi
}
