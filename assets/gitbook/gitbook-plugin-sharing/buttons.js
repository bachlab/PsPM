require(['gitbook', 'jquery'], function(gitbook, $) {
    var SITES = {
        'bluesky': {
            'label': 'Twitter',
            'icon': 'fa fa-twitter',
            'onClick': function(e) {
                e.preventDefault();
                window.open('https://bsky.app/profile/bachlab.bsky.social');
            }
        },
        'github': {
            'label': 'Github',
            'icon': 'fa fa-github',
            'onClick': function(e) {
                e.preventDefault();
                window.open('https://github.com/bachlab/PsPM');
            }
        },
    };



    gitbook.events.bind('start', function(e, config) {
        var opts = config.sharing;

        // Create dropdown menu
        var menu = $.map(opts.all, function(id) {
            var site = SITES[id];

            return {
                text: site.label,
                onClick: site.onClick
            };
        });

        // Create main button with dropdown
        if (menu.length > 0) {
            gitbook.toolbar.createButton({
                icon: 'fa fa-share-alt',
                label: 'Share',
                position: 'right',
                dropdown: [menu]
            });
        }

        // Direct actions to share
        $.each(SITES, function(sideId, site) {
            if (!opts[sideId]) return;

            var onClick = site.onClick;
            
            // override target link with provided link
            var side_link = opts[`${sideId}_link`]
            if (side_link !== undefined && side_link !== "") {
                onClick = function(e) {
                    e.preventDefault();
                    window.open(side_link);
                }
            }

            gitbook.toolbar.createButton({
                icon: site.icon,
                label: site.text,
                position: 'right',
                onClick: onClick
            });
        });
    });
});
