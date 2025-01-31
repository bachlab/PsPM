require(['gitbook', 'jquery'], function(gitbook, $) {
    var SITES = {
        'bluesky': {
            'label': 'Bluesky',
            'icon': `
								<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 530" width="16" height="16" fill="currentColor">
										<path d="M300,0C134.3,0,0,134.3,0,300s134.3,300,300,300s300-134.3,300-300S465.7,0,300,0z M300,550
												c-137.5,0-250-112.5-250-250S162.5,50,300,50s250,112.5,250,250S437.5,550,300,550z"/>
										<path d="M300,100c-110.5,0-200,89.5-200,200s89.5,200,200,200s200-89.5,200-200S410.5,100,300,100z M300,450
												c-82.7,0-150-67.3-150-150s67.3-150,150-150s150,67.3,150,150S382.7,450,300,450z"/>
								</svg>
						`,
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
