!function(){function a(a){$("#"+a+"_btn").click(function(){var t=o("ac_container"),e={};e.app="ac-set",e.action=a,e.ap_list=t,$.post("/",e,function(a){Ha.showNotify(a)},"json")})}function t(){$.post("/","app=ac-set&action=get_aps_list",function(a){$("#ac_container").empty();for(var t=0;t<a.length;t++){var s=e(a[t]);$("#ac_container").append(s)}$('[data-target="#editAcModal"]').click(function(){$("#editAcModal").find(".modal-body").empty();var a=$(this).attr("data-data"),t=JSON.parse(a),e=n(t);$("#editAcModal").find(".modal-body").append(e),$("#enc_type").change(function(){var a=$(this).val();"none"==a?$("#key_container").addClass("hidden"):$("#key_container").removeClass("hidden"),$("#key_container").find("input").val("")})}),$("#submit_edit_ac_btn").click(function(){var a=$("#mac_input").val(),t=$("#ver_input").val(),e=$("#ip_input").val(),n=$("#desc_input").val(),s=[],i=$("#enc_type").val(),o=$("#enc_key").val();$("#ssid_group").find("input").each(function(){s.push($(this).val())});var c={app:"ac-set",action:"edit_ac",mac:a,ver:t,ip:e,desc:n,ssid:s,enc:i,key:o};Ha.ajax("/","json",c,"post","",function(a){Ha.showNotify(a),a.status||$("#editAcModal").modal("hide")},1)}),$('[data-target="#clientModal"]').click(function(){$("#select_all_client").prop("checked",!1),$("#client_container").html("Loading...");var a=$(this).attr("data-mac"),t={app:"ac-set",action:"get_ap_clients",mac:a};$.post("/",t,function(t){if($("#client_container").empty(),!t)return void $("#client_container").html("未发现设备。");var e='<div class="table-responsive"><table class="table"><thead><tr><th></th><th>Signal</th><th>Mac/IP</th><th>Rate</th><th>operate</th></tr></thead><tbody id="client_table"></tbody></table></div>';$("#client_container").append(e);for(var n in t){var s=t[n].IP?t[n].IP:"设备未设置",o=n.replace(/:/g,""),c='<tr><td><input type="checkbox" data-mac="'+n+'"></td><td><div class="" id="sta-item-'+o+'"><div class="rssi-icon"><span></span><span></span><span></span><span></span></div><br><span class="rssi-text"></span></div></td><td><span>Mac:&nbsp;'+n+"</span><br><span>IP:&nbsp;"+s+"</span></td><td><span>Rx:&nbsp;"+t[n].rx_bitrate+"&nbsp;MBit/s</span><br><span>Tx:&nbsp;"+t[n].tx_bitrate+'&nbsp;MBit/s</span></td><td><button data-mac="'+n+'" class="btn btn-danger btn-xs">Kick out</button></td></tr>';$("#client_table").append(c),Ha.setRssiIcon(o,t[n].signal_pct)}i("select_all_client","client_container"),$("#client_table").find("button").click(function(){var t=$(this).attr("data-mac"),e={app:"ac-set",action:"kick_out_client",mac:t,ap_mac:a};$.post("/",e,function(a){Ha.showNotify(a),a.status||$("#clientModal").modal("hide")},"json")})},"json")}),i("selectAll","ac_container"),Ha.setFooterPosition(),$("#ac_container :checkbox,#selectAll").click(function(){c=0,$("#ac_container :checkbox").each(function(){$(this).prop("checked")&&(c+=1)}),c?$("#operate_btn").find("button").prop("disabled",!1):$("#operate_btn").find("button").prop("disabled",!0)})},"json")}function e(a){var t,e=JSON.stringify(a),n=a.SSID?a.SSID.replace(/,/g,"<br>"):"",i=a.Desc?a.Desc:"未设置",o=a.BW_up&&a.BW_down?'<span class="glyphicon glyphicon-arrow-up"></span>'+a.BW_up+'<br><span class="glyphicon glyphicon-arrow-down"></span>'+a.BW_down:"未连接",c=a.Quota_used&&a.Quota_total&&"undefined"!=typeof a.Quota_pused?""+a.Quota_used+"/"+a.Quota_total+"<br>"+a.Quota_pused+"%":"未连接",l=s(a.Uptimes),d=(new Date).getTime();t="undefined"==typeof a.Id?"glyphicon glyphicon-asterisk alert-warning":0==a.Enabled?"glyphicon glyphicon-asterisk alert-danger":a.Time+300<Math.floor(d/1e3)?"glyphicon glyphicon-asterisk alert-default":"glyphicon glyphicon-asterisk alert-success";var r='<tr data-mac="'+a.Mac+'"><td><input type="checkbox" name="" value="'+a.Mac+'" data-id=""></td><td class="like-a-link" data-mac="'+a.Mac+'" data-toggle="modal" data-target="#clientModal"><span class="'+t+'">'+a.Clients+"</span><br>v"+a.Version+"</td><td>"+l+"<br>M:"+a.Loads_pmem+"%&nbsp;C:"+a.Loads_pcpu+'%</td><td class="like-a-link" data-data=\''+e+'\' data-toggle="modal" data-target="#editAcModal">'+i+"</td><td>"+a.Mac+"<br>"+a.IP+"</td><td>"+n+"</td><td>"+a.Enc+":<br>"+a.Key+"</td><td>"+o+"</td><td>"+c+"</td></tr>";return r}function n(a){var t=a.Desc?a.Desc:"",e=a.SSID.split(","),n="",s="",i="",o="",c="",l="";"none"==a.Enc?(s="selected",c="hidden",l=""):"psk2"==a.Enc?(i="selected",l=a.Key):(o="selected",l=a.Key);for(var d=0;d<e.length;d++)n+='<input type="text" class="form-control" id="" name="" value="'+e[d]+'">';var r='<form name="eidt_client_form" class="form-horizontal"><input type="hidden" id="mac_input" value="'+a.Mac+'"><input type="hidden" id="ver_input" value="'+a.Version+'"><div class="form-group"><label for="" class="control-label col-sm-2">Desc</label><div class="col-sm-10"><input type="text" class="form-control" id="desc_input" name="" value="'+t+'"></div></div><div class="form-group" id="ssid_group"><label for="" class="control-label col-sm-2">SSID</label><div class="col-sm-10">'+n+'</div></div><div class="form-group"><label for="" class="control-label col-sm-2">IP</label><div class="col-sm-10"><input type="text" class="form-control" id="ip_input" name="" value="'+a.IP+'"></div></div><div class="form-group"><label for="" class="control-label col-sm-2">Enc</label><div class="col-sm-10"><select id="enc_type" name="" value="wpa2" class="form-control"><option value="none" '+s+'>None</option><option value="psk2" '+i+'>PSK2</option><option value="mixed-psk" '+o+'>Mixed</option></select></div></div><div class="form-group '+c+'" id="key_container"><label for="" class="control-label col-sm-2">Key</label><div class="col-sm-10"><input id="enc_key" name="" value="'+l+'" class="form-control"></div></div></form>';return r}function s(a){if(a<=0)return"";var t="";return t=a<60?t+a+"秒":a<3600?t+Math.floor(a/60)+"分"+a%60+"秒":a<86400?t+Math.floor(a/3600)+"小时"+Math.floor(a%3600/60)+"分"+a%60+"秒":t+Math.floor(a/86400)+"天"+Math.floor(a%86400/3600)+"小时"+Math.floor(a%86400%3600/60)+"分"+a%60+"秒"}function i(a,t){$("#"+a).click(function(){$("#"+t+" :checkbox").prop("checked",$("#"+a).prop("checked"))})}function o(a){var t=[];return $("#"+a+" :checkbox").each(function(){$(this).prop("checked")&&t.push($(this).val())}),t}var c=0;t(),i("select_all_fw","fw_list"),i("select_all_restore","restore_file_list"),$("#operate_btn").find("button").click(function(){if(c=0,$("#ac_container :checkbox").each(function(){$(this).prop("checked")&&(c+=1)}),!c)return!1}),$("#upload-fw").change(function(){var a=$(this).val(),t=a.split("\\").pop();$("#file_name").html(t)}),$("#upload_fw_btn").click(function(){$("#uploadFWModal").find(".form-group").removeClass("hidden"),$("#submit_flash").addClass("hidden"),$("#submit_upload").removeClass("hidden"),$("#uploadFWModal").find(".modal-title").html("Upload FW"),$("#uploadFWModal").find("table").addClass("hidden"),$("#fw_select").addClass("hidden"),$("#file_desc").empty()}),a("reboot"),a("enable"),a("disable"),$("#submit_upload").click(function(){var a="ifm"+Math.random(),t=$('<iframe width="0" height="0" frameborder="0" name="'+a+'">');return t.appendTo($("body")),$("#uploader").attr("target",a),$("#uploader").submit(),t.load(function(){var a=$(this.contentDocument).find("pre").html();if(a=JSON.parse(a),a.md5){Ha.showNotify({status:0,msg:"Upload success."});var t="<div><span>File:&nbsp;&nbsp;"+a.file+"</span><br><span>MD5:&nbsp;&nbsp;"+a.md5+"</span><br><span>Size:&nbsp;&nbsp;"+a.size+"</span></div>";$("#uploadFWModal").find(".form-group").addClass("hidden"),$("#uploadFWModal").find(".modal-title").html("刷机"),$("#uploadFWModal").find("table").removeClass("hidden"),$("#submit_flash").removeClass("hidden"),$("#fw_select").removeClass("hidden"),$("#submit_upload").addClass("hidden"),$("#file_desc").append(t)}else Ha.showNotify(a);this.remove()}),!1}),$("#submit_flash").click(function(){var a={};return a.bak_file=[],a.ap_list=o("ac_container"),$("#fw_list :checkbox").each(function(){$(this).prop("checked")&&a.bak_file.push($(this).val())}),a.app="ac-set",a.action="flash_ap",$.post("/",a,function(a){Ha.showNotify(a),a.status||$("#uploadFWModal").modal("hide")},"json"),!1}),$("#submit_restore").click(function(){var a={};return a.bak_file=[],a.ap_list=o("ac_container"),a.bak_file=o("restore_file_list"),a.app="ac-set",a.action="restore_ap",$.post("/",a,function(a){Ha.showNotify(a),a.status||$("#restoreModal").modal("hide")},"json"),!1}),$("#submit_ssid").click(function(){var a={};a.app="ac-set",a.action="setssid_ap",a.ap_list=o("ac_container"),a.ssid_24g=$("#set_ssid_form").find('[name="ssid_24g"]').val(),a.ssid_58g=$("#set_ssid_form").find('[name="ssid_58g"]').val(),a.enc=$("#enc_types").val(),a.key=$("#enc_keys").val(),Ha.ajax("/","json",a,"post","",function(a){Ha.showNotify(a),a.status||$("#ssidSetModal").modal("hide")},1)}),$("#submit_bw").click(function(){var a={};a.app="ac-set",a.action="bw_set",a.ap_list=o("ac_container"),a.total=$("#bw_set_form").find('[name="total"]').val(),$.post("/",a,function(a){Ha.showNotify(a),a.status||$("#bwModal").modal("hide")},"json")}),$('[data-target="#ssidSetModal"]').click(function(){$("#enc_types").val("none"),$("#enc_keys").parent().parent().addClass("hidden")}),$("#enc_types").change(function(){var a=$(this).val();"none"==a?($("#enc_keys").parent().parent().addClass("hidden"),$("#enc_keys").val("")):($("#enc_keys").parent().parent().removeClass("hidden"),$("#enc_keys").val(""))}),$("#kick_out_clients_btn").click(function(){var a=$('[data-target="#clientModal"]').attr("data-mac"),t=[];$("#client_table :checkbox").each(function(){$(this).prop("checked")&&t.push($(this).attr("data-mac"))});var e={app:"ac-set",action:"kick_out_clients",mac:t,ap_mac:a};return e.mac.length<=0?void Ha.showNotify({status:1,msg:"没有选择设备。"}):void $.post("/",e,function(a){Ha.showNotify(a),a.status||$("#clientModal").modal("hide")},"json")})}();