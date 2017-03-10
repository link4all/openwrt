function mapRuleData(e){for(var t=[],a=0;a<e.length;a++){var r={};r.Set_Service_Class_To=e[a]["class"],r.order=e[a].test_order/100,e[a].srcport&&(r.Source_Port=e[a].srcport),e[a].connbytes_kb&&(r.Connection_bytes_reach=e[a].connbytes_kb),e[a].source&&(r.Source_IP=e[a].source),e[a].destination&&(r.Destination_IP=e[a].destination),e[a].dstport&&(r.Destination_Port=e[a].dstport),e[a].max_pkt_size&&(r.Maximum_Packet_Length=e[a].max_pkt_size),e[a].min_pkt_size&&(r.Minimum_Packet_Length=e[a].min_pkt_size),e[a].proto&&(r.Transport_Protocol=e[a].proto),e[a].layer7&&(r.Application_Layer7_Protocol=e[a].layer7),t.push(r)}return t}function unmapRuleData(e){for(var t=[],a=0;a<e.length;a++){var r={};r["class"]=e[a].Set_Service_Class_To,r.test_order=100*e[a].order,e[a].Source_Port&&(r.srcport=e[a].Source_Port),e[a].Connection_bytes_reach&&(r.connbytes_kb=e[a].Connection_bytes_reach),e[a].Source_IP&&(r.source=e[a].Source_IP),e[a].Destination_IP&&(r.destination=e[a].Destination_IP),e[a].Destination_Port&&(r.dstport=e[a].Destination_Port),e[a].Maximum_Packet_Length&&(r.max_pkt_size=e[a].Maximum_Packet_Length),e[a].Minimum_Packet_Length&&(r.min_pkt_size=e[a].Minimum_Packet_Length),e[a].Transport_Protocol&&(r.proto=e[a].Transport_Protocol),e[a].Application_Layer7_Protocol&&(r.layer7=e[a].Application_Layer7_Protocol),t.push(r)}return t}function resetForm(e){var t=$("#"+e);t.find("input,select").prop("disabled",!0),t.find('[name="Set_Service_Class_To"]').prop("disabled",!1),t.find("option").prop("selected",!1),t.find("input").val(""),t.find('[type="checkbox"]').prop({checked:!1,disabled:!1}),t.find('[type="hidden"]').prop("disabled",!1)}function formatData(e){for(var t={},a=0;a<e.length;a++){var r=e[a].name,o=e[a].value;t[r]=o}return t}function updateLoad(e){$(".load_container").each(function(t){for(var a=0;a<e.length;a++)$(this).attr("data-class")-1==a&&$(this).html(bpsToKbpsString(e[a]))})}function bpsToKbpsString(e){var t="*",a=parseInt(e)/1e3;return t=isNaN(a)?"*":a<1?a.toFixed(1)+"":a.toFixed(0)+""}function initLoadPbs(e){for(var t={bps:[],bytes:[],leaf:[]},a=0;a<e.length;a++){var r=null,o=NaN,n=null;t.bps.push(r),t.bytes.push(o),t.leaf.push(n)}return t}function removeSerClass(e,t){for(var a=[],r=0;r<t.length;r++)t[r].name!=e&&a.push(t[r]);return a}function makeDefaultClass(e,t){for(var a=0;a<e.length;a++){if("down"==t)var r='<option value="dclass_'+e[a][0]+'">'+e[a][1]+"</option>";else if("up"==t)var r='<option value="uclass_'+e[a][0]+'">'+e[a][1]+"</option>";$("#default_class").append(r),$("#service_class_down").append(r)}}function getClassName(e,t){for(var a,r=0;r<t.length;r++)t[r][0]==e.split("_").pop()&&(a=t[r][1]);return a}function getClassId(e){for(var t=[],a=0;a<e.length;a++){var r=[];r[0]=e[a]["class"],r[1]=e[a].name,t.push(r)}return t}function moveRuleDown(e,t){if(e==t.length)return t;for(var a,r=0;r<t.length;r++)t[r].order==e?(t[r].order+=1,a=t[r],t[r]=t[r+1]):t[r].order==e+1&&(t[r].order-=1,t[r]=a);return t}function moveRuleUp(e,t){if(1==e)return t;for(var a,r=0;r<t.length;r++)t[r].order==e-1?(t[r].order+=1,a=t[r],t[r]=t[r+1]):t[r].order==e&&(t[r].order-=1,t[r]=a);return t}function removeRule(e,t){for(var a=[],r=0;r<t.length;r++)t[r].order<e?a.push(t[r]):t[r].order>e&&(t[r].order-=1,a.push(t[r]));return a}function editRule(){var e=$("#rule_form").serializeArray();e=formatData(e);for(var t=0;t<rule_data.length;t++)rule_data[t].order==e.order&&(rule_data[t]=e);makeClRoleDom(rule_data)}function addRule(){var e=$("#rule_form").serializeArray(),t=formatData(e);return t.order=rule_data.length+100,rule_data.push(t),makeClRoleDom(rule_data),!1}function updateLoadData(e){var t;"up"==e?t="app=qos-shellgui&action=get_"+e+"load_speed&wan="+currentWanIf:"down"==e&&(t="app=qos-shellgui&action=get_"+e+"load_speed"),$.post("/",t,function(e){var t=e.match(/hfsc\s1:[0-9]{1,2}\s.+leaf.+\n.+Sent\s[0-9]+/g),a=new Date,r=a.getTime()-lasttime;if(lasttime=a.getTime(),null!=t){for(i=0;i<t.length;i++){var o,n=parseInt(t[i].match(/hfsc\s1:([0-9]+)/)[1])-2;n<load.bps.length&&(o=load.bytes[n],load.bytes[n]=t[i].match(/Sent\s([0-9]+)/)[1],load.leaf[n]=t[i].match(/leaf\s([0-9a-f]*)/)[1],null!=o?load.bps[n]=8e3*(parseInt(load.bytes[n])-parseInt(o))/r:load.bps[n]=NaN)}updateLoad(load.bps)}})}var origin_data,rule_data,service_class_data,classes,default_class,total_bw,load,updateLoadInterval,ccstatus,target_ip,ping_limit,d=new Date,lasttime=d.getTime();