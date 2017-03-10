function setBrowserTimeCookie(){var e=Math.floor((new Date).getTime()/1e3);document.cookie="browser_time="+e+"; path=/"}function getRequestObj(){var e;try{e=new XMLHttpRequest}catch(t){try{e=new ActiveXObject("Msxml2.XMLHTTP")}catch(t){try{e=new ActiveXObject("Microsoft.XMLHTTP")}catch(t){return!1}}}return e}function runAjax(e,t,n,a){setBrowserTimeCookie();var s=getRequestObj();return s&&(s.onreadystatechange=function(){a(s)},"POST"==e?(n=null==n?" ":n,s.open("POST",t,!0),s.setRequestHeader("Content-type","application/x-www-form-urlencoded"),s.send(n)):"GET"==e&&(s.open("GET",t+"?"+n,!0),s.send(null))),s}function getParameterDefinition(e,t){return encodeURIComponent(e)+"="+encodeURIComponent(t)}function parseBytes(e,t,n,a){var s;return t="KBytes"!=t&&"MBytes"!=t&&"GBytes"!=t&&"TBytes"!=t?"mixed":t,spcr=null==n||0==n?" ":"",s="mixed"==t&&e>1099511627776||"TBytes"==t?(e/1099511627776).toFixed(a||3)+spcr+(n?"TB":"TBy"):"mixed"==t&&e>1073741824||"GBytes"==t?(e/1073741824).toFixed(a||3)+spcr+(n?"GB":"GBy"):"mixed"==t&&e>1048576||"MBytes"==t?(e/1048576).toFixed(a||3)+spcr+(n?"MB":"MBy"):(e/1024).toFixed(a||3)+spcr+(n?"KB":"KBy")}function getSelectedValue(e,t){return t=null==t?document:t,null==t.getElementById(e)?void alert(UI.Err+": "+e+" "+UI.nex):(selectedIndex=t.getElementById(e).selectedIndex,selectedValue="",selectedIndex>=0&&(selectedValue=t.getElementById(e).options[t.getElementById(e).selectedIndex].value),selectedValue)}function initializePieCharts(){uploadClassIds=[],downloadClassIds=[],uploadClassNames=[],downloadClassNames=[];var e=[],t=[];for(monitorIndex=0;monitorIndex<monitorNames.length;monitorIndex++){var n=monitorNames[monitorIndex];if(n.match(/qos/)){var a=n.match(/up/),s=n.match(/down/),o=n.split("-");o.shift(),o.shift(),o.pop(),o.pop();var d=o.join("-"),l=uciOriginal.get("qos_shellgui",d,"name");a&&null==e[d]&&(uploadClassIds.push(d),uploadClassNames.push(l),e[d]=1),s&&null==t[d]&&(downloadClassIds.push(d),downloadClassNames.push(l),t[d]=1)}}initPieChart(uploadClassNames,[1,1,1,1],downloadClassNames,[1,1,1,1]),setInterval(updatePieCharts,2e3)}function getMonitorId(e,t,n,a,s){var o,d=null,l="",i="";if("total"==n?l=s?"total"+t+"B":"total"+t+"A":n.match(/qos/)?(l="qos"+t,i=a):"ip"==n&&(l="bdist"+t),"none"!=n)for(o=0;o<monitorNames.length&&null==d;o++){var r=monitorNames[o];!(r.match("up")&&e||r.match("down")&&!e)||""!=l&&!r.match(l)||""!=i&&!r.match(i)||(d=r)}return d}function updatePieCharts(){if(!updateInProgress){updateInProgress=!0;var e=["up","down"],t=[];for(directionIndex=0;directionIndex<e.length;directionIndex++){var n=e[directionIndex],a="up"==n?uploadClassIds:downloadClassIds,s=parseInt(getSelectedValue(n+"_timeframe"));for(classIndex=0;classIndex<a.length;classIndex++)t.push(getMonitorId("up"==n,s,"qos",a[classIndex],!0))}var o=getParameterDefinition("monitor",t.join(" ")),d="app=qos-shellgui&action=get_bandwidth&"+o,l=function(e){if(4==e.readyState){var n=parseMonitors(e.responseText),a=["up","down"],s=[],o=[],d=[],l=[];for(directionIndex=0;directionIndex<a.length;directionIndex++){var i=a[directionIndex],r=[],u=0,p=[];for(nameIndex=0;nameIndex<t.length;nameIndex++)if(t[nameIndex].match(i)){var c=0,h=n[t[nameIndex]];if(null!=h){var m=h[0];c=parseInt(m[m.length-1])}r.push(c),u+=c}var g=0==u;if(g){var I;for(I=0;I<r.length;I++)r[I]=1,u++}for(nameIndex=0;nameIndex<r.length;nameIndex++){var x=i.match("up")?uploadClassNames:downloadClassNames;if(className=x[nameIndex],g){var f="("+truncateDecimal(100*(1/r.length))+"%)";p.push(className+" - "+parseBytes(r[nameIndex]-1,null,!0)+" "+f)}else{var f="("+truncateDecimal(100*r[nameIndex]/u)+"%)";p.push(className+" - "+parseBytes(r[nameIndex],null,!0)+" "+f)}}s=i.match("up")?r:s,o=i.match("up")?p:o,d=i.match("down")?r:d,l=i.match("down")?p:l}updatePieChart(s,o,d,l),updateInProgress=!1}};runAjax("POST","/",d,l)}}function parseMonitors(e){var t=new Array,n=e.split("\n");parseInt(n.shift());for(lineIndex=0;lineIndex<n.length;lineIndex++)n[lineIndex].length>0&&(monitorName=n[lineIndex],monitorName=monitorName.replace(/[\t ]+.*$/,""),lineIndex++,lineIndex++,lineIndex++,lastTimePoint=n[lineIndex],lineIndex++,points=n[lineIndex].split(","),t[monitorName]=[points,lastTimePoint]);return t}function truncateDecimal(e){return result=""+Math.floor(1e3*e)/1e3,decMatch=result.match(/.*\.(.*)$/),null==decMatch?result+=".000":1==decMatch[1].length?result+="00":2==decMatch[1].length&&(result+="0"),result}function initPieChart(e,t,n,a){ctx_up=document.getElementById("uploadChart"),ctx_down=document.getElementById("downloadChart");for(var s=["#8E44AD","#E74C3C","#27AE60","#2980B9","#7F8C8D","#BDC3C7","#F1C40F","#16A085","#E67E22","#34495E"],o=s.slice(0,e.length),d=0;d<e.length;d++){var l='<div class="legend_item" style="background-color: '+o[d]+'"><span class="legend_label">&nbsp;&nbsp;<span id="up_legend_text_'+d+'">'+e[d]+' - loading...</span></span><span class="line-through hidden"></span></div>';$("#up_legend_container").append(l)}for(var d=0;d<n.length;d++){var l='<div class="legend_item" style="background-color: '+o[d]+'"><span class="legend_label">&nbsp;&nbsp;<span id="down_legend_text_'+d+'">'+n[d]+' - loading...</span></span><span class="line-through hidden"></span></div>';$("#down_legend_container").append(l)}$(".legend_item").click(function(){$(this).find(".line-through").hasClass("hidden")?($(this).find(".line-through").removeClass("hidden"),updatePieCharts()):($(this).find(".line-through").addClass("hidden"),updatePieCharts())}),data_up={labels:e,datasets:[{data:t,backgroundColor:o,hoverBackgroundColor:o}]},data_down={labels:n,datasets:[{data:a,backgroundColor:o,hoverBackgroundColor:o}]},upPieChart=new Chart(ctx_up,{type:"pie",data:data_up,options:{legend:{display:!1},tooltips:{enabled:!0,callbacks:{label:function(e,t){var t=t.labels[e.index],n=[],a=t.split("-").shift(),s=t.split("-").pop().replace(" ","");return n.push(a),a!=s&&n.push(s),n}}}}}),downPieChart=new Chart(ctx_down,{type:"pie",data:data_down,options:{legend:{display:!1},tooltips:{enabled:!0,callbacks:{label:function(e,t){var t=t.labels[e.index],n=[],a=t.split("-").shift(),s=t.split("-").pop().replace(" ","");return n.push(a),a!=s&&n.push(s),n}}}}}),Ha.setFooterPosition()}function updatePieChart(e,t,n,a){for(var s=0;s<t.length;s++)$("#up_legend_text_"+s).html(t[s]);for(var s=0;s<a.length;s++)$("#down_legend_text_"+s).html(a[s]);$(".legend_item").each(function(){var t=$(this).find(".line-through").hasClass("hidden"),a=$(this).find(".legend_label").find("span").prop("id"),s=a.split("_").shift(),o=a.split("_").pop();"up"==s?t||(e[o]=0):t||(n[o]=0)});var o=e;upPieChart.config.data.datasets[0].data=o,upPieChart.config.data.labels=t,upPieChart.update();var d=n;downPieChart.config.data.datasets[0].data=d,downPieChart.config.data.labels=a,downPieChart.update(),Ha.setFooterPosition()}var UI=new Object,TiZ=new Object;window.onresize=function(){try{"block"==document.getElementById("darken").style.display&&setControlsEnabled(!1,"block"==document.getElementById("wait_msg").style.display)}catch(e){}};var qosStr=new Object,uploadClassIds=[],downloadClassIds=[],uploadClassNames=[],downloadClassNames=[],uploadUpdateInProgress=!1,downloadUpdateInProgress=!1,updateInProgress=!1,setUploadPie=null,setDownloadPie=null,ctx_up,ctx_down,data_up,data_down,upPieChart,downPieChart;$("#up_timeframe,#down_timeframe").change(function(){updatePieCharts()}),initializePieCharts();