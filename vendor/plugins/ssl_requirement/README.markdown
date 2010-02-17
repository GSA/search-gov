###Fork of ssl_requirement to add

 - if a action is ssl_allowed and ssl_required -- it is ssl_required
 - support :all
 - `ssl_required` == `ssl_required :all`
 - allow attributes as array `ssl_required [:login, :register]`
 - allow arrays of strings as attributes `ssl_required 'login', 'register'` / `ssl_required %w[login register]`
 - running tests
 - ability to overwrite ssl_host, to make custom host changes e.g. `def ssl_host; request.sll? ? 'xxx.com' : 'yyy.com';end`

` script/plugin install git://github.com/grosser/ssl_requirement.git `


SSL Requirement
===============
 - redirect https to http by default
 - redirect http requests to https with `ssl_required`
 - allow https and http with `ssl_allowed`

Example:

    class ApplicationController < ActionController::Base
      include SslRequirement
    end

    class AccountController < ApplicationController
      ssl_required :signup, :payment
      ssl_allowed :index

      def signup
        # Non-SSL access will be redirected to SSL
      end

      def payment
        # Non-SSL access will be redirected to SSL
      end

      def index
        # This action will work either with or without SSL
      end

      def other
        # SSL access will be redirected to non-SSL
      end
    end
  
You can overwrite the protected method ssl_required? to rely on other things
than just the declarative specification. Say, only premium accounts get SSL.

When including SslRequirement it adds `before_filter :ensure_proper_protocol`.

### Separate ssl host?
    class ApplicationController < ActionController::Base
      include SslRequirement

      def ssl_host
        Rails.env.production ? 'myhost.com' : request.host
      end
    end

### No ssl in development? (not recommended, [TATFT](http://dawanda.com/product/3861630-TATFT-Mousepad-Test-all-the-fucking-time))
    class ApplicationController < ActionController::Base
      include SslRequirement
      skip_before_filter :ensure_proper_protocol unless Rails.env.production?
    end

Authors
=======

###Original
Copyright (c) 2005 David Heinemeier Hansson, released under the MIT license

###Additions
 - [Michael Grosser](http://pragmatig.wordpress.com)
 - [Johndouthat](http://github.com/johndouthat)
 - [Adam Wiggins](http://adam.blog.heroku.com/)
