function setCanvasHeight(){var e=$(window).width();e>=768&&($(".canvas_container").empty(),$("#total_container").append('<canvas id="my_total"></canvas>'),$("#download_container").append('<canvas id="my_download" height="200"></canvas>'),$("#upload_container").append('<canvas id="my_upload" height="200"></canvas>'))}function stopInterval(){null!=updateInterval&&clearInterval(updateInterval)}function trim(e){return e?e.replace(/^\s\s*/,"").replace(/\s\s*$/,""):e}function BandwidthCookieContainer(){this.prefix="shellgui.bandwidth_display.",this.set=function(e,t){var n=new Date((new Date).getTime()+864e7);document.cookie=this.prefix+e+"="+escape(t)+";expires="+n.toUTCString()},this.remove=function(e){var t=new Date(0);document.cookie=this.prefix+e+";expires="+t.toUTCString()},this.get=function(e,t){for(var n=document.cookie.split(";"),o=0;o<n.length;o++){var a=n[o].split("=");if(trim(a[0])==this.prefix+e)return trim(a[1])}return t}}function initializePlotsAndTable(){var e=bandwidthSettings.get("plot_time_frame","1"),t=bandwidthSettings.get("table_time_frame","1");setSelectedValue("plot_time_frame",e),setCurrentTimeFrameBtn(e),setSelectedValue("table_time_frame",t),setSelectedValue("table_units","mixed"),document.getElementById("use_high_res_15m").checked="1"==uciOriginal.get("shellgui","bandwidth_display","high_res_15m");var n,o=!1,a=!1,l=!1,i=!1;for(n=0;n<monitorNames.length;n++){var d=monitorNames[n];if(d.match(/qos/)){var r=d.match(/up/),s=d.match(/down/);o=o||r,a=a||s;var u=d.split("-");u.shift(),u.shift(),u.pop(),u.pop();var p=u.join("-"),m=uciOriginal.get("qos_shellgui",p,"name");r&&null==definedUploadClasses[p]&&(qosUploadClasses.push(p),qosUploadNames.push(m),definedUploadClasses[p]=1),s&&null==definedDownloadClasses[p]&&(qosDownloadClasses.push(p),qosDownloadNames.push(m),definedDownloadClasses[p]=1)}l=!!d.match(/tor/)||l,i=!!d.match(/openvpn/)||i}var c,h=["plot1_type","plot2_type","plot3_type","table_type"];for(c=0;c<h.length;c++){var g=h[c];o&&addOptionToSelectElement(g,UI.QoS_Upload_Class,"qos-upload"),a&&addOptionToSelectElement(g,UI.QoS_Download_Class,"qos-download"),l&&addOptionToSelectElement(g,"Tor","tor"),i&&addOptionToSelectElement(g,"OpenVPN","openvpn"),addOptionToSelectElement(g,UI.Hostname,"hostname"),addOptionToSelectElement(g,"IP","ip");var f=bandwidthSettings.get(g,"none");setSelectedValue(g,f)}plotsInitializedToDefaults=!1,uploadMonitors=["","",""],downloadMonitors=["","",""],updateInProgress=!1,setTimeout(resetPlots,150),updateInterval=setInterval(doUpdate,2e3)}function getMonitorId(e,t,n,o,a){var l,i=null,d="",r="",s=uciOriginal.get("shellgui","bandwidth_display","high_res_15m");if(t=1!=t||"total"==n||n.match(/tor/)||n.match(/openvpn/)||"1"!=s||a?t:0,"total"==n?d=a?"bdist"+t:"total"+t:n.match(/qos/)?e&&n.match(/up/)||!e&&n.match(/down/)?(d="qos"+t,r=o):n="none":n.match(/tor/)?d=a?"tor-lr"+t:"tor-hr"+t:n.match(/openvpn/)?d=a?"openvpn-lr"+t:"openvpn-hr"+t:"ip"!=n&&"hostname"!=n||(d="bdist"+t),"none"!=n)for(l=0;l<monitorNames.length&&null==i;l++){var u=monitorNames[l];!(u.match("up")&&e||u.match("down")&&!e)||""!=d&&!u.match(d)||""!=r&&!u.match(r)||(i=u)}return i}function getHostnameList(e){var t=[],n=0;for(n=0;n<e.length;n++){var o=e[n],a=null==ipToHostname[o]?o:ipToHostname[o];a=a.length<25?a:a.substr(0,22)+"...",t.push(a)}return t}function resetPlots(){if(window.my_total_line&&(window.my_total_line=void 0),window.my_upload_line&&(window.my_upload_line=void 0),window.my_download_line&&(window.my_download_line=void 0),updateInProgress||null==updateTotalPlot||null==updateUploadPlot||null==updateDownloadPlot)setTimeout(resetPlots,25),null!=updateTotalPlot&&null!=updateDownloadPlot&&null!=updateUploadPlot||(updateTotalPlot=updateTotalLine,updateDownloadPlot=updateDownloadLine,updateUploadPlot=updateUploadLine);else{updateInProgress=!0;var e=tableDownloadMonitor,t=tableUploadMonitor,n=downloadMonitors.join("\n")+"\n",o=uploadMonitors.join("\n");uploadMonitors=[],downloadMonitors=[];var a,l=getSelectedValue("plot_time_frame"),i=getSelectedValue("table_time_frame"),d=!1;for(a=1;a<=3;a++){var r=getSelectedValue("plot"+a+"_type"),s=1==l&&"1"==uciOriginal.get("shellgui","bandwidth_display","high_res_15m");d=d||"total"!=r&&"none"!=r&&"tor"!=r&&"openvpn"!=r&&!s}for(a=1;a<=4;a++){var u=a<4?"plot"+a+"_id":"table_id",p=a<4?u:u+"_container",m=a<4?"plot"+a+"_type":"table_type",c=getSelectedValue(m),h=getSelectedValue(u);if(h=null==h?"":h,"ip"==c||"hostname"==c?(null==h.match(/^[0-9]+\./)&&("hostname"==c?setAllowableSelections(u,ipsWithData,getHostnameList(ipsWithData)):setAllowableSelections(u,ipsWithData,ipsWithData),setSelectedValue(u,ipsWithData[0]),h=null==ipsWithData[0]?"":ipsWithData[0]),$("#"+p).removeClass("hidden")):"qos-upload"==c?(null==definedUploadClasses[h]&&(setAllowableSelections(u,qosUploadClasses,qosUploadNames),h=qosUploadClasses[0]),$("#"+p).removeClass("hidden")):"qos-download"==c?(null==definedDownloadClasses[h]&&(setAllowableSelections(u,qosDownloadClasses,qosDownloadNames),h=qosDownloadClasses[0]),$("#"+p).removeClass("hidden")):$("#"+p).addClass("hidden"),!plotsInitializedToDefaults&&""!=c&&"none"!=c&&"total"!=c&&"tor"!=c&&"openvpn"!=c){var g=bandwidthSettings.get(u,"none");""==g||"ip"!=c&&"hostname"!=c||setAllowableSelections(u,[g],[g]),setSelectedValue(u,g),h=g}if(4!=a)uploadMonitors[a-1]=getMonitorId(!0,l,c,h,d),downloadMonitors[a-1]=getMonitorId(!1,l,c,h,d),uploadMonitors[a-1]=null==uploadMonitors[a-1]?"":uploadMonitors[a-1],downloadMonitors[a-1]=null==downloadMonitors[a-1]?"":downloadMonitors[a-1];else{var f="total"!=c||4!=i;i=f?i:5,tableUploadMonitor=getMonitorId(!0,i,c,h,f),tableDownloadMonitor=getMonitorId(!1,i,c,h,f),tableUploadMonitor=null==tableUploadMonitor?"":tableUploadMonitor,tableDownloadMonitor=null==tableDownloadMonitor?"":tableDownloadMonitor}}for(plotsInitializedToDefaults=!0,updateInProgress=!1,o==uploadMonitors.join("\n")&&n==downloadMonitors.join("\n")&&t==tableUploadMonitor&&e==tableDownloadMonitor||doUpdate(),bandwidthSettings.set("plot_time_frame",getSelectedValue("plot_time_frame")),bandwidthSettings.set("table_time_frame",getSelectedValue("table_time_frame")),a=1;a<=4;a++){var u=a<4?"plot"+a+"_id":"table_id",m=a<4?"plot"+a+"_type":"table_type",c=getSelectedValue(m);bandwidthSettings.set(m,c),""!=c&&"none"!=c&&"total"!=c?bandwidthSettings.set(u,getSelectedValue(u)):(bandwidthSettings.remove(u),bandwidthSettings.remove(m))}}}function updateTotalLine(e,t,n,o,a,l,i){var d=getDisplayData(e,n,t),r=getDisplayTime(e,n,o,a,t),s=getDisplayLabel(e);"undefined"==typeof my_total_line?makeLine("my_total",d,r,i.Total,s):updateLine("my_total",d,r)}function updateDownloadLine(e,t,n,o,a,l,i){var d=getDisplayData(e,n,t),r=getDisplayTime(e,n,o,a,t),s=getDisplayLabel(e);"undefined"==typeof my_download_line?makeLine("my_download",d,r,i.Download,s):updateLine("my_download",d,r)}function updateUploadLine(e,t,n,o,a,l,i){var d=getDisplayData(e,n,t),r=getDisplayTime(e,n,o,a,t),s=getDisplayLabel(e);"undefined"==typeof my_upload_line?makeLine("my_upload",d,r,i.Upload,s):updateLine("my_upload",d,r)}function getDisplayLabel(e){for(var t={},n=0;n<3;n++)if(e[n]){var o=getSelectedValue("plot"+(n+1)+"_type");"none"!=o&&"total"!=o&&(o+="-"+$('[value="'+getSelectedValue("plot"+(n+1)+"_id")+'"]').html()),t[n]=o}return t}function getDisplayData(e,t,n){for(var o=getIntervalSeconds(t),a={},l=0;l<3;l++)if(e[l]){for(var i=[],d=e[l],r=d.length<parseInt(n)+1?parseInt(n)+1:d.length,s=0;s<r;s++)"undefined"!=typeof d[s]?i.push(d[s]/1024/parseInt(o)):i.unshift(0);a[l]=i}return a}function getIntervalSeconds(e){var t;return t="minute"==e?60:"hour"==e?3600:"day"==e?24576:"month"==e?12582912:parseInt(e)}function getLastMonth(e){var t=1e3*parseInt(e);t=new Date(t);var n=t.getFullYear(),o=t.getMonth();return 0==o?(n-=1,o=11):o-=1,t.setFullYear(n),t.setMonth(o),t.getTime()/1e3}function getLastYear(e){var t=1e3*parseInt(e);t=new Date(t);var n=t.getFullYear();return t.setFullYear(n-1),t.getTime()/1e3}function getTimeStr(e,t){var n=1e3*parseInt(e);n=new Date(n);var o=n.getFullYear(),a=n.getMonth()+1,l=n.getDate(),i=n.getHours(),d=n.getMinutes(),r=n.getSeconds();return t.replace("YYYY",add0(o)).replace("MM",add0(a)).replace("dd",add0(l)).replace("hh",add0(i)).replace("mm",add0(d)).replace("ss",add0(r))}function makeLine(e,t,n,o,a){var l=[];if(t[0]){var i={label:a[0],data:t[0],pointRadius:0,pointHitRadius:0,fill:!1,borderWidth:1,borderColor:"#5bc0de"};l.push(i)}if(t[1]){var d={label:a[1],data:t[1],pointRadius:0,pointHitRadius:0,fill:!1,borderWidth:1.5,borderColor:"#5cb85c"};l.push(d)}if(t[2]){var r={label:a[2],data:t[2],pointRadius:0,pointHitRadius:0,fill:!1,borderWidth:2,borderColor:"#d9534f"};l.push(r)}var s,u;u=getSelectedValue("plot_time_frame"),s=u>3?u>4?"GByte / day":"MByte / hr":"KByte / s";var p={type:"line",data:{labels:n,datasets:l},options:{animation:{duration:0},responsive:!0,title:{display:!0,text:o},scales:{xAxes:[{display:!0}],yAxes:[{display:!0,beginAtZero:!1,scaleLabel:{display:!0,labelString:s}}]}}},m=document.getElementById(e).getContext("2d");window[e+"_line"]=new Chart(m,p)}function updateLine(e,t,n){var o=[];for(var a in t)o.push(t[a]);for(var l=0;l<window[e+"_line"].config.data.datasets.length;l++)window[e+"_line"].config.data.datasets[l].data=o[l];window[e+"_line"].config.data.labels=n,window[e+"_line"].update()}function getDisplayTime(e,t,n,o,a){var l,i=(getXaxesFormate(),getSelectedValue("plot_time_frame")),d=n;l=1==i?n-900:2==i?n-21600:3==i?n-86400:4==i?getLastMonth(n):getLastYear(n);for(var r,s=0;s<3;s++)if(e[0]||e[1]||e[2]){for(var u=[],p=e[0]||e[1]||e[2],m=p.length<parseInt(a)+1?parseInt(a)+1:p.length,c=0;c<m;c++)u.push("");r=u}else{for(var u=[],m=parseInt(a)+1,c=0;c<m;c++)u.push("");r=u}r[0]=l,r[r.length-1]=d;var h=getTimeLabels();return r=h(r)}function getXaxesFormate(){var e,t,n,o=getSelectedValue("plot_time_frame"),a=getSelectedValue("plot1_type"),l=getSelectedValue("plot2_type"),i=getSelectedValue("plot3_type");return 1==o?(e=5,t=16,n="hh:mm"):2==o?(e=6,t=25,n="hh:00"):3==o?(e=6,t=25,n="hh:00"):4==o?(e=5,t=32,n="MM-dd"):5==o&&(e=6,t=13,n="YYYY-MM月"),"total"==a&&"none"==l&&"none"==i&&(t=450,n="hh:mm:ss"),data={timeFrame:o,labelCounts:e,pointCounts:t,labelFormate:n}}function add0(e){return e>9?e:"0"+e}function get15MinsLabels(e){var t=e.length;e[0],e[t-1];if(16==t){for(var n=1;n<t;n++)e[n]=e[0]+60*n;for(var n=0;n<t;n++)e[n]=getTimeStr(e[n],"hh:mm"),n%3==0&&0!=n||(e[n]="")}else if(450==t){for(var n=t-2;n>=0;n--)e[n]=e[t-1]-2*(449-n);for(var n=0;n<t;n++)e[n]=getTimeStr(e[n],"hh:mm:ss"),n%30==0&&0!=n||(e[n]="")}return e}function get6HoursLabels(e){var t=e.length,n=(e[0],e[t-1]);if(25==t){for(var o=t-2;o>=0;o--)e[o]=n-900*(24-o);for(var o=0;o<t;o++)e[o]=getTimeStr(e[o],"hh:mm"),"00"!=e[o].split(":").pop()&&(e[o]="")}else if(360==t){for(var o=t-2;o>=0;o--)e[o]=n-60*(359-o);for(var o=0;o<t;o++)e[o]=getTimeStr(e[o],"hh:mm"),"00"!=e[o].split(":").pop()&&(e[o]="")}return e}function get24HoursLabels(e){var t=e.length,n=(e[0],e[t-1]);if(25==t){for(var o=t-2;o>=0;o--)e[o]=n-3600*(24-o);for(var o=0;o<t;o++)e[o]=getTimeStr(e[o],"hh:00"),o%4==0&&0!=o||(e[o]="")}else if(480==t){for(var o=t-2;o>=0;o--)e[o]=n-180*(479-o);for(var o=0;o<t;o++)e[o]=getTimeStr(e[o],"hh:mm"),"00"!=e[o].split(":").pop()&&(e[o]="")}return e}function get30DaysLabels(e){var t=e.length,n=(e[0],e[t-1]);if(t<50){for(var o=t-2;o>=0;o--)e[o]=n-86400*(t-1-o);for(var o=0;o<t;o++)e[o]=getTimeStr(e[o],"MM-dd"),o%5==0&&0!=o||(e[o]="")}else if(t>50){for(var o=t-2;o>=0;o--)e[o]=n-7200*(t-1-o);for(var o=0;o<t;o++)e[o]=getTimeStr(e[o],"MM-dd"),o%60==0&&0!=o||(e[o]="")}return e}function get1YearLabels(e){var t=e.length,n=(e[0],e[t-1]);if(13==t){for(var o=t-2;o>=0;o--)e[o]=getLastMonth(e[o+1]);for(var o=0;o<t;o++)e[o]=getTimeStr(e[o],"MM月"),o%2==0&&0!=o||(e[o]="")}else{for(var o=t-2;o>=0;o--)e[o]=n-86400*(t-1-o);for(var o=0;o<t;o++)e[o]=getTimeStr(e[o],"MM-dd"),"01"!=e[o].split("-").pop()&&(e[o]="")}return e}function getTimeLabels(){var e,t=getSelectedValue("plot_time_frame");return 1==t?e=get15MinsLabels:2==t?e=get6HoursLabels:3==t?e=get24HoursLabels:4==t?e=get30DaysLabels:5==t&&(e=get1YearLabels),e}function parseMonitors(e){var t=[],n=e.split(/[\r\n]+/),o=parseInt(n.shift());if(""+o=="NaN")return t;var a;for(a=0;a<n.length;a++)if(null!=n[a]&&n[a].length>0&&n[a].match(/ /)){var l=n[a].split(/[\t ]+/)[0],i=n[a].split(/[\t ]+/)[1];a++;n[a];a++;n[a];a++;var d=n[a];if(null!=n[a+1]&&(n[a+1].match(/,/)||n[a+1].match(/^[0-9]+$/))){a++;var r=n[a].split(",");t[l]=null==t[l]?[]:t[l],t[l][i]=[r,d,o],found=1}}return t}function getDisplayIp(e){var t=e;return null!=t&&null!=currentWanIp&&null!=currentLanIp&&""!=t&&(t=t==currentWanIp?currentLanIp:t),t}function getRealIp(e){var t=e;return null!=t&&null!=currentWanIp&&null!=currentLanIp&&""!=currentWanIp&&""!=currentLanIp&&""!=t&&(t=t==currentLanIp?currentWanIp:t),t}function doUpdate(){if(!updateInProgress&&null!=updateUploadPlot&&null!=updateDownloadPlot&&null!=updateTotalPlot){updateInProgress=!0;var e=uploadMonitors.join(" ")+" "+downloadMonitors.join(" ")+" "+tableDownloadMonitor+" "+tableUploadMonitor,t="app=bandwidth-usage&action=get_bandwidth&"+getParameterDefinition("monitor",e),n=function(e){if(4==e.readyState){try{clearTimeout(updateTimeoutId)}catch(t){}if(updateReq=null,e.responseText.length>0&&!e.responseText.match(/ERROR/)){var n=parseMonitors(e.responseText),o=[],a=[],l=[],i=[],d=[],r=0,s=2,u=0,p=2,m=Math.floor((new Date).getTime()/1e3),c=m,h=m;for(monitorIndex=0;monitorIndex<4;monitorIndex++){var g;for(g=0;g<2;g++){var f,v,w=!1;if(monitorIndex<3){var I=0==g?downloadMonitors:uploadMonitors;f=0==g?a:o,v=I[monitorIndex]}else f=i,v=0==g?tableDownloadMonitor:tableUploadMonitor;v=null==v?"":v;var b=monitorIndex<3?"plot"+(monitorIndex+1)+"_type":"table_type",_=getSelectedValue(b),y=""==v?null:n[v];if(null!=y){var T,M=[];for(T in y)(("total"==_||_.match("qos")||_.match("tor")||_.match("openvpn"))&&"COMBINED"==T||"total"!=_&&"COMBINED"!=T)&&M.push(getDisplayIp(T));if(M.length>0){var U=v.split("-");if(monitorIndex<3?(r=U.pop(),s=U.pop()):(u=U.pop(),p=U.pop()),v.match("bdist")&&"total"!=_){var S=monitorIndex<3?"plot"+(monitorIndex+1)+"_id":"table_id";T=getSelectedValue(S),T=null==T?"":getRealIp(T);var x=$("#"+S).val();null==y[T]&&x==T&&(Ha.showNotify({status:2,msg:UI.Host_IP+":"+T+UI.have_nothing_data_at_this_period}),bandwidthSettings.set(S,M[0])),T=null!=y[T]?T:M[0],"hostname"==_?setAllowableSelections(S,M,getHostnameList(M)):setAllowableSelections(S,M,M),ipsWithData=M}else T=M[0];T=null==T?"":getRealIp(T);var D=y[T][0];monitorIndex<3?(m=y[T][1],c=y[T][2]):h=y[T][1];var C;C=monitorIndex<3?null==l[monitorIndex]?[]:l[monitorIndex]:d;var B;for(B=0;B<D.length;B++){var L=D.length-(1+B),P=C.length<D.length?B:C.length-D.length+B;null!=C[P]?C[P]=parseInt(C[P])+parseInt(D[L]):C.push(D[L])}monitorIndex<3&&(l[monitorIndex]=C),f.push(D),w=!0}else if(v.match("bdist")&&monitorIndex<3){var b=monitorIndex<3?"plot"+(monitorIndex+1)+"_type":"table_type",S=monitorIndex<3?"plot"+(monitorIndex+1)+"_id":"table_id";I[monitorIndex]="",setSelectedValue(b,"none"),$("#"+S).addClass("hidden")}}else if(v.match("bdist")&&"total"!=_&&monitorIndex<3){var S=monitorIndex<3?"plot"+(monitorIndex+1)+"_id":"table_id";I[monitorIndex]="",setSelectedValue(b,"none"),$("#"+S).addClass("hidden")}w||f.push(null)}monitorIndex<3?l[monitorIndex]=null==l[monitorIndex]?null:l[monitorIndex].reverse():(d.reverse(),i.unshift(d))}updateTotalPlot(l,r,s,m,c,tzMinutes,UI),updateDownloadPlot(a,r,s,m,c,tzMinutes,UI),updateUploadPlot(o,r,s,m,c,tzMinutes,UI),updateBandwidthTable(i,p,h)}updateInProgress=!1}},o=function(){updateInProgress=!1};updateReq=runAjax("POST","/",t,n),updateTimeoutId=setTimeout(o,5e3)}}function twod(e){var t=""+e;return t=1==t.length?"0"+t:t}function updateBandwidthTable(e,t,n){var o=[],a=0,l=getSelectedValue("table_units"),i=n,d=new Date;d.setTime(1e3*i),d.setUTCMinutes(d.getUTCMinutes()+tzMinutes),"NaN"==parseInt(t)&&(t.match(/month/)||t.match(/day/))&&(d=new Date(d.getTime()+108e5));var r=UI.EMonths;for(a=0;a<e[0].length;a++){var s=0,u=[];for(s=0;s<3;s++){var p=e[s],m=null==p?0:p[p.length-(1+a)];m=null==m?0:m,u.push(parseBytes(m,l))}var c="";t.match(/minute/)?(c=""+twod(d.getUTCHours())+":"+twod(d.getUTCMinutes()),d.setUTCMinutes(d.getUTCMinutes()-1)):t.match(/hour/)?(c=""+twod(d.getUTCHours())+":"+twod(d.getUTCMinutes()),d.setUTCHours(d.getUTCHours()-1)):t.match(/day/)?(c=r[d.getUTCMonth()]+" "+d.getUTCDate(),d.setUTCDate(d.getUTCDate()-1)):t.match(/month/)?(c=r[d.getUTCMonth()]+" "+d.getUTCFullYear(),d.setUTCMonth(d.getUTCMonth()-1)):"NaN"!=parseInt(t)&&(c=parseInt(t)>=2419200?r[d.getUTCMonth()]+" "+d.getUTCFullYear()+" "+twod(d.getUTCHours())+":"+twod(d.getUTCMinutes()):parseInt(t)>=86400?r[d.getUTCMonth()]+" "+twod(d.getUTCHours())+":"+twod(d.getUTCMinutes()):""+twod(d.getUTCHours())+":"+twod(d.getUTCMinutes()),d.setTime(d.getTime()-1e3*parseInt(t))),u.unshift(c),o.push(u),i=d.getTime()/1e3}updateTableData(o)}function highResChanged(){setControlsEnabled(!1,!0,bndwS.RstGr);var e=document.getElementById("use_high_res_15m").checked,t=[];t.push("uci set shellgui.bandwidth_display=bandwidth_display"),t.push("uci set shellgui.bandwidth_display.high_res_15m="+(e?"1":"0")),t.push("uci commit"),t.push("/usr/shellgui/progs/bwmond restart");var n=function(e){4==e.readyState&&(window.location=window.location,setControlsEnabled(!0))},o="app=bandwidth-usage&action=get_bandwidth&monitor=bdist1-upload-minute-15   bdist1-download-minute-15   bdist1-download-minute-15 bdist1-upload-minute-15";runAjax("POST","/",o,n)}function deleteData(){if(0!=confirm(bndwS.DelAD)){setControlsEnabled(!1,!0,bndwS.DelDW);var e=[];e.push("/usr/shellgui/progs/bwmond stop"),e.push("rm /tmp/data/bwmon/*"),e.push("rm /usr/data/bwmon/*"),e.push("/usr/shellgui/progs/bwmond start");var t=function(e){4==e.readyState&&setControlsEnabled(!0)},n="app=bandwidth-usage&action=get_bandwidth&monitor=bdist1-upload-minute-15   bdist1-download-minute-15   bdist1-download-minute-15 bdist1-upload-minute-15";runAjax("POST","/",n,t)}}function setSelectedValue(e,t,n){var n=null==n?document:n,o=n.getElementById(e),a=!1;for(optionIndex=0;optionIndex<o.options.length&&!a;optionIndex++)a=o.options[optionIndex].value==t,a&&(o.selectedIndex=optionIndex);!a&&o.options.length>0&&o.selectedIndex<0&&(o.selectedIndex=0)}function getSelectedValue(e,t){return t=null==t?document:t,null==t.getElementById(e)?void alert(UI.Err+": "+e+" "+UI.nex):(selectedIndex=t.getElementById(e).selectedIndex,selectedValue="",selectedIndex>=0&&(selectedValue=t.getElementById(e).options[t.getElementById(e).selectedIndex].value),selectedValue)}function addOptionToSelectElement(e,t,n,o,a){a=null==a?document:a,option=a.createElement("option"),option.text=t,option.value=n;try{a.getElementById(e).add(option,o)}catch(l){null==o?a.getElementById(e).add(option):a.getElementById(e).add(option,o.index)}}function setBrowserTimeCookie(){var e=Math.floor((new Date).getTime()/1e3);document.cookie="browser_time="+e+"; path=/"}function getParameterDefinition(e,t){return encodeURIComponent(e)+"="+encodeURIComponent(t)}function removeStringFromArray(e,t){var n,o=[];for(n=0;n<e.length;n++){var a=!1;"string"==typeof e[n]&&(a=e[n]==t),a||o.push(e[n])}return o}function runAjax(e,t,n,o){setBrowserTimeCookie();var a=getRequestObj();return a&&(a.onreadystatechange=function(){o(a)},"POST"==e?(n=null==n?" ":n,a.open("POST",t,!0),a.setRequestHeader("Content-type","application/x-www-form-urlencoded"),a.send(n)):"GET"==e&&(a.open("GET",t+"?"+n,!0),a.send(null))),a}function getRequestObj(){var e;try{e=new XMLHttpRequest}catch(t){try{e=new ActiveXObject("Msxml2.XMLHTTP")}catch(t){try{e=new ActiveXObject("Microsoft.XMLHTTP")}catch(t){return!1}}}return e}function setAllowableSelections(e,t,n,o){null==o&&(o=document);var a=o.getElementById(e);if(null!=n&&null!=t&&null!=a){var l=!0;if(t.length==a.options.length)for(l=!1,optionIndex=0;optionIndex<a.options.length&&!l;optionIndex++)l=l||a.options[optionIndex].text!=n[optionIndex]||a.options[optionIndex].value!=t[optionIndex];if(l){for(currentSelection=getSelectedValue(e,o),removeAllOptionsFromSelectElement(a),addIndex=0;addIndex<t.length;addIndex++)addOptionToSelectElement(e,n[addIndex],t[addIndex],null,o);setSelectedValue(e,currentSelection,o)}}}function removeAllOptionsFromSelectElement(e){for(;e.length>0;)try{e.remove(0)}catch(t){}}function parseBytes(e,t,n,o){var a;return t="KBytes"!=t&&"MBytes"!=t&&"GBytes"!=t&&"TBytes"!=t?"mixed":t,spcr=null==n||0==n?" ":"",a="mixed"==t&&e>1099511627776||"TBytes"==t?(e/1099511627776).toFixed(o||3)+spcr+(n?UI.TB:UI.TBy):"mixed"==t&&e>1073741824||"GBytes"==t?(e/1073741824).toFixed(o||3)+spcr+(n?UI.GB:UI.GBy):"mixed"==t&&e>1048576||"MBytes"==t?(e/1048576).toFixed(o||3)+spcr+(n?UI.MB:UI.MBy):(e/1024).toFixed(o||3)+spcr+(n?UI.KB:UI.KBy)}function setCurrentTimeFrameBtn(e){$(".tf_btn").each(function(){$(this).removeClass("active")}),$("#plot_tf_"+e+",#plot_tf_xs_"+e).addClass("active")}function updateTableData(e){$("#bw_table_container").empty();for(var t=0;t<e.length;t++){var n="<tr><td>"+e[t][0]+"</td><td>"+e[t][1]+"</td><td>"+e[t][2]+"</td><td>"+e[t][3]+"</td></tr>";$("#bw_table_container").append(n)}}UI.byt="bytes",UI.Bu="B",UI.KB="kB",UI.MB="MB",UI.GB="GB",UI.TB="TB",UI.KB1="kByte",UI.MB1="MByte",UI.GB1="GByte",UI.TB1="TByte",UI.KBy="kBytes",UI.MBy="MBytes",UI.GBy="GBytes",UI.TBy="TBytes",UI.Kbs="kbits/s",UI.KBs="kBytes/s",UI.MBs="MBytes/s",setBrowserTimeCookie(),$(window).load(setCanvasHeight);var testAjax=getRequestObj();testAjax||(window.location="no_ajax.sh");var bndwS=new Object,ipMonitorIds,qosUploadMonitorIds,qosDownloadMonitorIds,uploadMonitors=null,downloadMonitors=null,tableUploadMonitor=null,tableDownloadMonitor=null,ipsWithData=[],qosDownloadClasses=[],qosDownloadNames=[],qosUploadClasses=[],qosUploadNames=[],definedUploadClasses=[],definedDownloadClasses=[],updateTotalPlot=null,updateUploadPlot=null,updateDownloadPlot=null,updateInProgress=!1,plotsInitializedToDefaults=!1,expandedWindows=[],expandedFunctions=[],updateInterval=null;window.onbeforeunload=stopInterval;var bandwidthSettings=new BandwidthCookieContainer,updateReq=null,updateTimeoutId=null;$(".dropdown-menu").find("a").click(function(e){e.preventDefault()}),$("#table_type").change(function(){var e=$(this).val();if("qos-upload"==e||"qos-download"==e||"hostname"==e||"ip"==e){var t=$("#table_id").html();$("#table_id_shown").removeClass("hidden").html(t)}else{var n="";$("#table_id_shown").addClass("hidden").html(n)}$("#table_type_shown").val(e)}),$(".tf_btn").click(function(){var e=$(this).prop("id").split("_").pop();$(".tf_btn").each(function(){$(this).removeClass("active");var t=$(this).prop("id").split("_").pop();t==e&&$(this).addClass("active")}),$("#plot_time_frame").val(e),resetPlots()}),initializePlotsAndTable();