            "sharing": {

                "github": true,
              {% if site.github_username %}
                "github_link": "https://github.com/{{ site.github_username }}",
              {% else %}
                "github_link": "https://github.com",
              {% endif %}

                "bluesky": true,

                "all": ["github", "bluesky"]
            },
