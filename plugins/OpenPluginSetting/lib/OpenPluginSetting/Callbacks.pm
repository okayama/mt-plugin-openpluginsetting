package OpenPluginSetting::Callbacks;
use strict;

sub _cb_save_config_filter {
    my $app = MT->instance();
    my $this_plugin_id = $app->param( 'plugin_id' );
    $app->add_return_arg( 'saved_plugin' => $this_plugin_id );
    $app->request( 'saved_plugin', $this_plugin_id );
    1;
}

sub _cb_cms_post_run {
    my $app = MT->instance();
    if ( my $saved_plugin = $app->request( 'saved_plugin' ) ) {
        $app->{ redirect } .= '#plugin-' . $saved_plugin;
    }
}

sub _cb_tp_cfg_plugin {
    my ( $cb, $app, $param ) = @_;
    if ( my $saved_plugin_id = $app->param( 'saved_plugin' ) ) {
        for my $loop ( @{ $param->{ plugin_loop } } ) {
            if ( $loop->{ plugin_id } eq $saved_plugin_id ) {
                $loop->{ 'is_saved' } = 1;
            }
        }
    }
    my $js =<<'SCRIPT';
hash=location.hash;
jQuery(hash).addClass('plugin-expanded');
tab=jQuery(hash+' .plugin-content .icon-mini-comments').parent('li.tab');
jQuery(tab).removeClass('ui-tabs-selected ui-state-active ui-tabs-active');
tab=jQuery(hash+' .plugin-content .icon-mini-settings').parent('li.tab');
jQuery(tab).addClass('ui-tabs-selected ui-state-active ui-tabs-active');
SCRIPT
    $param->{ jq_js_include } = $param->{ jq_js_include } . "\n" . $js;
}

sub _cb_ts_cfg_plugin {
    my ( $cb, $app, $tmpl ) = @_;
    my $search = quotemeta( '<fieldset>' );
    my $insert =<<'MTML';
<input type="hidden" name="plugin_id" value="<mt:var name="plugin_id">">
<mt:if name="saved">
  <mt:if name="is_saved">
    <mt:setvarblock name="message_id">plugin-<mt:var name="plugin_id">-message</mt:setvarblock>
    <mtapp:statusmsg
       id="$message_id"
       class="success">
      <__trans phrase="Your plugin settings have been saved.">
    </mtapp:statusmsg>
  </mt:if>
</mt:if>
MTML
    $$tmpl =~ s/($search)/$insert$1/
}

1;
