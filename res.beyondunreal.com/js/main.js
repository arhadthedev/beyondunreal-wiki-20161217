
function setStylesheet(skin){if(!skin)
return;$$('head link').each(function(lnk){if(lnk.getAttribute("rel").indexOf("style")!=-1&&lnk.getAttribute("title"))
lnk.disabled=!(lnk.getAttribute("title")==skin);});}
var tabs;var tabc_cont;var tabc_list;var tab_id_re=/^#tab-(.*)$/;function load_tabs(){var tab_bar=$('feature-tab-bar');if(!tab_bar){return;}
tabs=tab_bar.getElements('a');tabc_cont=$('feature-tab-area');tabc_list=[];tabc_cont.getChildren().each(function(this_el){if(this_el.tagName=="DIV"){this.push(this_el);this_el.setProperty('static','true');this_el.addClass('tab-content');}},tabc_list);$A(document.links).each(function(link){if(tab_id_re.test(link.hash)){link.onclick=function(){activate_tab(this.hash);return false;}}},this);if(document.location.hash!=''){activate_tab(document.location.hash);}}
function activate_tab(hash){var res=tab_id_re.exec(hash);if(res){tab_id_re.exec();var tab_id=res[1];tabs.each(function(this_tab){this_tab.removeClass('active-tab');if(this_tab.hash==hash)
{this_tab.addClass('active-tab');}});var tabc=$('tabc-'+tab_id);if(!tabc){tabc=new Element("div").setProperty('id','tabc-'+tab_id).addClass('tab-content').injectInside(tabc_cont);tabc_list.push(tabc);}
tabc_list.each(function(this_tab){if(this_tab!=tabc){this_tab.setStyle('display','none');}});tabc.setStyle('display','block');if(tabc.getProperty('static')!='true'){get_dynamic_content(tab_id,tabc);}
if(window.getScrollTop()>$('feature-tab-bar').getTop()){effect=new Fx.Scroll($(window),{});effect.toTop();}}}
function get_dynamic_content(tab_id,tabc){tabc.innerHTML='<div class="tab-loading">Loading...</div>';var req=new Ajax('/ajax_functions.php',{method:'post',data:{'action':'loadTab','tab':tab_id},update:tabc}).request();if(!req){tabc.innerHTML='<div class="tab-error">Unable to request data, check your browser settings!</div>';}}
window.addEvent('domready',load_tabs);