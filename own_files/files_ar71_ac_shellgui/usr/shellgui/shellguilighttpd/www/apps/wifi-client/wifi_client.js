!function(){Ha.mask.show();var i=[];Ha.ajax("/","json","app=wifi-client&action=get_nics_sta","post","",function(s){$("#nic_container").empty();for(nic in s)for(nic_item in s[nic]){var n;s[nic][nic_item];i.push(nic_item),n=s[nic][nic_item].disabled?UI.Unailable:UI.Available;var a='<div class="row nic_item" id="nic_item_'+nic_item+'"><div class="col-sm-12" style="margin-bottom: 10px"><h2 class="app-sub-title">'+nic_item+"<small>("+n+")</small></h2><span>"+UI.Wireless_Channel+":&nbsp;&nbsp;"+s[nic][nic_item].channel+"</span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>"+UI.Hardware_Mode+":&nbsp;&nbsp;"+s[nic][nic_item].hwmode+'</span><div class="pull-right"><a href="/?app=wifi-client&action=dev_scan&dev='+nic_item+'"><button class="btn btn-default btn-sm">'+UI.Scan+"</button></a></div></div></div>";$("#nic_container").append(a);var e,c;if(s[nic][nic_item].sta){e=s[nic][nic_item].sta;var t=e.ssid,d=e.sig_p;t=t.replace(/[^0-9a-zA-Z_\-]/g,""),c='<div class="media col-sm-10 media_'+nic_item+'" id="sta-item-'+t+'"><div class="media-left"><div class="rssi-icon"><span></span><span></span><span></span><span></span></div><span class="rssi-text"></span></div><div class="media-body row wireless-content"><h4 class="media-heading col-xs-12">'+e.ssid+'</h4><p class="col-xs-12 col-sm-4">BSSID:&nbsp;'+e.bssid+'</p><p class="col-xs-12 col-sm-4">Encryption:&nbsp;'+e.enc+'</p></div></div><div class="pull-right" id="disable_btn_'+nic_item+'"><button class="btn btn-danger btn-sm disable_ssid_btn" id="disable_ssid_'+nic_item+'">'+UI.Drop+'</button></div><hr class="col-sm-12">'}else c="<div>"+UI.There_is_no_AP_avaible+"</div><hr>";$("#nic_container").append(c),Ha.setRssiIcon(t,d)}$(".disable_ssid_btn").click(function(){var i=$(this).prop("id").replace("disable_ssid_","");$.post("/","app=wifi-client&action=drop_client&dev="+i,function(s){Ha.showNotify(s),$(".media_"+i).addClass("hidden"),$("#disable_btn_"+i).addClass("hidden"),$("#nic_item_"+i).after("<div>"+UI.There_is_no_AP_avaible+"</div>")},"json")}),Ha.mask.hide()},1)}();