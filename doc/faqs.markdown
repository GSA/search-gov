# FAQs XML Feed

There are two types of FAQs: weekly and monthly.  We only pull in the weekly ones at this point (one for spanish, one for english).  The entire FAQ tables is wiped before reload.


## Tasks

To load a faq xml file 

>  rake usasearch:faq:load faq_file_name=... locale=...

To grab the latest xml file via sftp

>  rake usasearch:faq:grab_and_load locale=...

In both cases, locale is optional.

Other things to know:

- locale defaults to en in both cases
- the location and access tokens are located in config/faq.yml
- the grab_and_load leaves a file under tmp/faq.  If the file already exists, any future grab_and_load will not reload the Faq table.  You can still do that but you will have to use `rake usasearch:faq:load` to forece the reload.


## Configuration

In order to use the grab_and_load, create a config file called config/faq.yml containing something like this:

>defaults: &defaults
>  protocol: sftp
>  dir_path: outbox
>  host: localhost
>  username: admin
>  password: secret
>  file_name_pattern:
>    en: ^weekly_english_xml_content_feed_[0-9]+.xml$
>    es: ^weekly_spanish_xml_content_feed_[0-9]+.xml$
>
>development:
>  <<: *defaults
>
>test:
>  <<: *defaults

