#!/usr/bin/haserl --upload-limit=8192 --upload-dir=/tmp/
<% 
rm -f /tmp/firmware.img
mv $HASERL_file_path /tmp/firmware.img
printf "Location: /?app=firmware&action=preflash&file=$POST_file_name\r\n\r\n"
exit
%>

