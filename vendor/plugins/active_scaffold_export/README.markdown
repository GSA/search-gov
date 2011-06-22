active_scaffold_export
======================

Active Scaffold plugin for CSV exports.

Introduction
------------

This Active Scaffold plugin provides a configurable CSV 'Export'
action for Active Scaffold controllers.

Installation
------------

You can use active_scaffold_export with the latest Rails 3, but you'll
need to also install the vhochstein port of active_scaffold.

    $ rails plugin install git://github.com/vhochstein/active_scaffold.git

In your Gemfile:

    gem "active_scaffold_export"

Features
--------

* Uses FasterCSV for CSV generation
* Works with Rails 3 (thanks vhochstein!)
* Scales to many, many records (thanks Alexander Malysh!)
* Let the user pick which columns to export.
* Download full lists or just a single page.
* Don't like commas? No problem, uses your favorite delimiter!
* Don't need no stinkin' headers?  Drop 'em.

Usage
-----

    active_scaffold :users do |config|
      actions.add :export  # this is required, all other configuration is optional

      export.columns = [ :id, :email, :created_at ]  # uses list columns by default
      export.allow_full_download = false             # defaults to true
      export.show_form = true                        # whether to show customization form or not, default to true
      export.force_quotes = true                          # defaults to false
      export.default_deselected_columns = [ :created_at ] # optional
      export.default_delimiter = ';'                      # defaults to ','
      export.default_skip_header = true                   # defaults to false
      export.default_full_download = false                # defaults to true
    end

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2010 Mojo Tech, LLC. See MIT-LICENSE for details.
