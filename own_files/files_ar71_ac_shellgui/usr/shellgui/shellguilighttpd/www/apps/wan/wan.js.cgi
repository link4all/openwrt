#!/usr/bin/haserl
Content-Type: text/javascript; charset=utf-8

<% eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' wan ${FORM_lang}) %>
(function(){
    $('form,input,[type="submit"]').prop('disabled',true);
    $.post('/',{'app':'wan','action': 'wan_check_net'},function(data){
        for(var key in data){
            if(!data[key].status){
                $('#wanType_' + key).html('<%= ${_LANG_Form_Connecting_Internet_Successfull} %>');
                $('#wanSet_' + key).addClass('hidden');
                $('#' + key + '_info').removeClass('hidden');
                $('#' + key + '_info_ip').html(data[key].ip);
                $('#' + key + '_info_mask').html(data[key].mask);
                $('#' + key + '_info_gateway').html(data[key].gateway);
                $('#' + key + '_info_dns').html(data[key].dns);
            }else{
                $('#wanType_' + key).html('<span class=\'text-danger\'><%= ${_LANG_Form_Connecting_Internet_Fail} %></span>');
                $('#wanSet_' + key).find('form,input,[type="submit"]').prop('disabled',false);
            }
        }
    },'json');

    $('.show-set-btn').on('click',function(){
            var wan_id = $(this).attr('id');
            var name = wan_id.split('_')[0];
            $('#' + name + '_info').addClass('hidden');
            $('#wanSet_' + name).removeClass('hidden');
            $('#wanSet_' + name).find('form,input,[type="submit"]').prop('disabled',false);
    });

    $('form').on('submit',function(){
        var form = $(this),
            data_order = form.find('[type="submit"]').attr('data-order'),
            data = 'app=wan&action=wan_' + form.attr('name') + '&wan=' + data_order + '&' + form.serialize();
        Ha.ajax('/','json',data,'post');

        return false;
    });
})();
