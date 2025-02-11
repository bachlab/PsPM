function channel_action = pspm_cfg_selector_channel_action

channel_action = cfg_menu;
channel_action.name = 'Channel action';
channel_action.tag  = 'channel_action';
channel_action.values = {'add', 'replace'};
channel_action.labels = {'Add', 'Replace'};
channel_action.val = {'add'};
channel_action.help = {'Choose whether to add a new channel, or to replace the last existing channel of the same type and with the same units (if any).'};
