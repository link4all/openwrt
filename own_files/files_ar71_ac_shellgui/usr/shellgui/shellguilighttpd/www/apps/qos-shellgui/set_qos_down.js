!function(){function a(t){$("#cl_roles_container").empty();for(var e=0;e<t.length;e++){var s=[];for(var r in t[e])if("Set_Service_Class_To"!=r&&"order"!=r){var d=r.replace(/_/g," ");s.push("<p>"+d+":"+t[e][r]+"</p>")}var l=s.join(""),n=getClassName(t[e].Set_Service_Class_To,classes),o='<tr class="text-left" id="rule_num_'+t[e].order+'"><td>'+l+"</td><td>"+n+'</td><td><button class="btn btn-info btn-xs edit_rule_btn" data-data=\''+JSON.stringify(t[e])+'\' data-toggle="modal" data-target="#ruleModal">'+UI.Edit+'</button></td><td><button class="btn btn-danger btn-xs remove_rule_btn" data-order="order_'+t[e].order+'">'+UI.Remove+'</button></td><td><button class="btn btn-info btn-xs move_up_btn" data-order="order_'+t[e].order+'"><span class="glyphicon glyphicon-arrow-up"></span></button></td><td><button class="btn btn-info btn-xs move_down_btn" data-order="order_'+t[e].order+'"><span class="glyphicon glyphicon-arrow-down"></span></button></td></tr>';$("#cl_roles_container").append(o)}$(".edit_rule_btn").click(function(){$("#ruleModal").find(".modal-title").html(UI.Edit_QoS_Classification_Rule),$("#rule_form").prop("name","editRuleForm"),resetForm("rule_form");var a=$(this).attr("data-data"),a=JSON.parse(a);for(var t in a){var e=$("#rule_form").find('[name="'+t+'"]');e.prop("disabled",!1),"order"!=t&&e.parent().parent().parent().find('[type="checkbox"]').prop("checked",!0),"text"==e.prop("type")||"hidden"==e.prop("type")?e.val(a[t]):(e.find("option").prop("selected",!1),e.find('[value="'+a[t]+'"]').prop("selected",!0))}}),$(".remove_rule_btn").click(function(){var t=$(this).attr("data-order").replace("order_","");rule_data=removeRule(t,rule_data),a(rule_data)}),$(".move_up_btn").click(function(){var t=parseInt($(this).attr("data-order").replace("order_",""));rule_data=moveRuleUp(t,rule_data),a(rule_data)}),$(".move_down_btn").click(function(){var t=parseInt($(this).attr("data-order").replace("order_",""));rule_data=moveRuleDown(t,rule_data),a(rule_data)})}function t(a){$("#service_class_container").empty();for(var e=0;e<a.length;e++){var s,r;s=a[e].min_bw?a[e].min_bw:"zero",r=a[e].max_bw?a[e].max_bw:"nolimit";var d='<tr class="text-left"><td>'+a[e].name+"</td><td>"+a[e].percent+"%</td><td>"+s+"</td><td>"+r+"</td><td>"+a[e].minRTT+'</td><td class="load_container" data-class="'+a[e]["class"]+'"></td><td><button class="btn btn-info btn-xs edit_class_btn" data-data=\''+JSON.stringify(a[e])+'\' data-toggle="modal" data-target="#classModal">'+UI.Edit+'</button></td><td><button class="btn btn-danger btn-xs remove_class_btn" data-name="'+a[e].name+'">'+UI.Remove+"</button></td></tr>";$("#service_class_container").append(d)}$(".load_container").each(function(a){for(var t=$(this).attr("data-class"),e=0;e<load.bps.length;e++)t-1==e&&$(this).html(bpsToKbpsString(load.bps[t-1]))}),$(".edit_class_btn").click(function(){$("#classModal").find(".modal-title").html(UI.Edit_QoS_Service_Class),$("#class_form").attr("data-name","EditClassForm"),resetForm("class_form");var a=$(this).attr("data-data"),a=JSON.parse(a);for(var t in a){var e=$("#class_form").find('[name="'+t+'"]');a[t]&&(e.val(a[t]),e.prop("disabled",!1),e.parent().parent().parent().find(".has_field").prop("checked",!0)),"radio"==e.prop("type")&&(e.prop("disabled",!1),a[t]?($("#rtt_yes").prop("checked",!0),$("#rtt_no").prop("checked",!1)):($("#rtt_yes").prop("checked",!1),$("#rtt_no").prop("checked",!0)))}}),$(".remove_class_btn").click(function(){var a=$(this).attr("data-name");service_class_data=removeSerClass(a,service_class_data),t(service_class_data)})}function e(){var a,e=$("#class_form").serializeArray();$("#class_form").find('[type="radio"]').each(function(){$(this).prop("checked")&&(a=$(this).attr("data-value"))});var s=formatData(e);return e.max_bw||(s.max_bw=!1),e.min_bw||(s.min_bw=!1),s.minRTT=a,service_class_data.push(s),t(service_class_data),!1}function s(){var a,e=$("#class_form").serializeArray();$("#class_form").find('[type="radio"]').each(function(){$(this).prop("checked")&&(a=$(this).attr("data-value"))}),e=formatData(e),e.max_bw||(e.max_bw=!1),e.min_bw||(e.min_bw=!1),e.minRTT=a;for(var s=0;s<service_class_data.length;s++)if(service_class_data[s].name===e.name){var r=service_class_data[s]["class"];service_class_data[s]=e,service_class_data[s]["class"]=r}return t(service_class_data),!1}function r(){$.post("/","app=qos-shellgui&action=get_qos_download",function(e){origin_data=e.rule_data,rule_data=mapRuleData(origin_data),service_class_data=e.class_data,load=initLoadPbs(service_class_data),classes=getClassId(service_class_data),default_class=e.download_default_class,total_bw=e.download_total_bandwidth,ccstatus=e.qos_monenabled,target_ip=e.ptarget_ip||"",ping_limit=e.pinglimit||"",a(rule_data),makeDefaultClass(classes,"down"),t(service_class_data),0==total_bw&&($("#page_switch").prop("checked",!1),$("input,button,select").prop("disabled",!0),$("#page_switch").prop("disabled",!1),clearInterval(updateLoadInterval)),ccstatus?d():l(),$("#default_class").find("option").each(function(){$(this).val()==default_class?$(this).prop("selected",!0):$(this).prop("selected",!1)}),$("#total_bw").val(total_bw)},"json")}function d(){$("#enable_cc").prop("checked",!0),$("#target_ip").parent().parent().find(".has_field").prop("disabled",!1),$("#target_ip").parent().parent().find("label").addClass("has_switch"),target_ip&&($("#target_ip").parent().parent().find(".has_field").prop("checked",!0),$("#target_ip").prop("disabled",!1).val(target_ip)),$("#ping_limit").parent().parent().find(".has_field").prop("disabled",!1),ping_limit&&($("#ping_limit").parent().parent().find(".has_field").prop("checked",!0),$("#ping_limit").prop("disabled",!1).val(ping_limit)),$("#ping_limit").parent().parent().find("label").addClass("has_switch")}function l(){$("#enable_cc").prop("checked",!1),$("#target_ip").parent().parent().find(".has_field").prop("checked",!1).prop("disabled",!0),$("#target_ip").prop("disabled",!0).val(target_ip),$("#ping_limit").parent().parent().find(".has_field").prop("checked",!1).prop("disabled",!0),$("#ping_limit").prop("disabled",!0).val(ping_limit)}r(),updateLoadInterval=setInterval(function(){updateLoadData("down")},1e3),$("#page_submit").click(function(){Ha.mask.show();var a={app:"qos-shellgui",action:"set_download",rule_data:unmapRuleData(rule_data),class_data:service_class_data,download_total_bandwidth:$("#total_bw").val(),download_default_class:$("#default_class").val(),pinglimit:ccstatus?$("#ping_limit").val():"",ptarget_ip:ccstatus?$("#target_ip").val():"",qos_monenabled:ccstatus};clearInterval(updateLoadInterval),$.post("/",a,function(a){Ha.showNotify(a),function(){Ha.mask.hide()}(),r(),updateLoadInterval=setInterval(function(){updateLoadData("down")},1e3)},"json")}),$("#page_switch").click(function(){var e=$(this).prop("checked");e?($("input,button,select").prop("disabled",!1),total_bw=3200,$("#total_bw").val(total_bw),$.post("/","app=qos-shellgui&action=total_bandwidth&up_down=download&total_bw=3200",Ha.showNotify,"json"),a(rule_data),makeDefaultClass(classes,"down"),t(service_class_data),updateLoadInterval=setInterval(function(){updateLoadData("down")},1e3)):($("input,button,select").prop("disabled",!0),total_bw=0,$("#total_bw").val(total_bw),$.post("/","app=qos-shellgui&action=total_bandwidth&up_down=download&total_bw=0",Ha.showNotify,"json"),clearInterval(updateLoadInterval)),$("#page_switch").prop("disabled",!1)}),$("#page_reset").click(function(){r()}),$("#enable_cc").click(function(){ccstatus?l():d(),ccstatus=!ccstatus}),$(".has_switch").click(function(){var a=$(this).parent().find(".has_field").prop("checked");$(this).parent().find(".has_field").prop("checked",!a);var t=$(this).prop("for");$("#"+t).prop("disabled",a)}),$(".has_field").change(function(){var a=$(this).prop("checked"),t=$(this).parent().find(".has_switch").prop("for");$("#"+t).prop("disabled",!a).focus()}),$("#add_rule_btn").click(function(){$("#ruleModal").find(".modal-title").html(UI.Add_New_Classification_Rule),$("#rule_form").prop("name","addRuleForm"),resetForm("rule_form")}),$("#submit_rule_btn").click(function(){"addRuleForm"==$("#rule_form").prop("name")?addRule():editRule()}),$("#add_class_btn").click(function(){$("#classModal").find(".modal-title").html(UI.Add_New_Service_Class),$("#class_form").attr("data-name","addClassForm"),resetForm("class_form"),$("#class_form").find('[name="name"],[name="percent"],[name="minRTT"]').prop("disabled",!1)}),$("#submit_class_btn").click(function(){"addClassForm"==$("#class_form").attr("data-name")?e():s()})}();