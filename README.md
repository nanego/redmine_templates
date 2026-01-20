Redmine Issue Templates Plugin
======================

This plugin adds the ability to create and use issue templates.
You can manage templates generation and visibility through roles, permissions and projects.

## Requirements

Note that this plugin depends on these other plugins:
* **redmine_base_deface** (get it [here](https://github.com/jbbarth/redmine_base_deface))

This plugin uses select2 to display select-boxes if a select2 plugin has been installed. You can find one here: [redmine_base_select2](https://github.com/jbbarth/redmine_base_select2).

You will also need a recent version of Ruby:

    ruby >= 3.1.0
    
## Test status

|Plugin branch| Redmine Version | Test Status       |
|-------------|-----------------|-------------------|
|master       | 6.0.8           | [![6.0.8][1]][5]  |
|master       | 6.1.1           | [![6.1.1][2]][5]  |
|master       | master          | [![master][3]][5] |

[1]: https://github.com/nanego/redmine_templates/actions/workflows/6_0_8.yml/badge.svg
[2]: https://github.com/nanego/redmine_templates/actions/workflows/6_1_1.yml/badge.svg
[3]: https://github.com/nanego/redmine_templates/actions/workflows/master.yml/badge.svg
[5]: https://github.com/nanego/redmine_templates/actions
