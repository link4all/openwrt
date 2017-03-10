#!/usr/bin/haserl
<%
if [ "$FORM_action" = "logout" ]; then
	shellgui '{"action": "del_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
	printf "Location: /?app=login\r\n\r\n"
	exit
fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h %>
<body>

<div class="container login-content">
  <div class="row">
    <div class="logo">
      <div class="">
        <span class="glyphicon glyphicon-fire"></span>
      </div>
      <h1><%= ${_LANG_Form_Wlelecome} %></h1>
    </div>

    <form class="form" name="loginform" method="post" id="loginform">
      <div class="form-group">
        <select class="form-control" id="lang" name="lang" onchange="lang_change()">
						<option value="zh-cn" <% [ "$COOKIE_lang" = "zh-cn" ] && printf 'selected="selected"'%>><%= ${_LANG_Form_lang_zh_cn} %></option>
						<option value="en" <% [ "$COOKIE_lang" = "en" ] && printf 'selected="selected"'%>><%= ${_LANG_Form_lang_en} %></option>
        </select>
      </div>
      <div class="form-group">
        <input type="text" class="form-control" name="username" required placeholder="<%= ${_LANG_Form_Username} %>" value="root">
      </div>
      <div class="form-group">
        <input type="password" class="form-control" name="password" required placeholder="<%= ${_LANG_Form_Password} %>">
      </div>
      <button type="submit" class="btn btn-default btn-block"><%= ${_LANG_Form_Login} %></button>
    </form>
  </div>
</div>

<% /usr/shellgui/progs/main.sbin h_end %>
<script>
  $('#loginform').on('submit', function(e){
  	e.preventDefault();
  	var data = "app=login&"+$(this).serialize();
  	var url = '/';
  	Ha.ajax(url, 'json', data, 'post', 'loginform');
  });

  function lang_change(){
  	var data = "app=home&action=change_lang&lang=" + $('#lang').val();
  	var url = '/';
  	Ha.ajax(url, 'json', data, 'post', 'loginform');
  };

  $('.gotop-widget').empty();//TODO same method can be used at the header or footer...
</script>

</body>
</html>