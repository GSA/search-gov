require 'spec_helper'

# All of these controllers are implemented as vanilla
# ActiveScaffold controllers consisting only of class
# method calls to configure the controller.
#
# Since we don't test their functionality explicitly, none
# are loaded during the spec run, which means that code
# coverage appears to be 0% for those controllers. Fix
# that here by simply autoloading the controllers.
describe Admin::I14yDrawersController do; end
describe Admin::LanguagesController do; end
describe Admin::NewsItemsController do; end
describe Admin::RoutedQueriesController do; end
describe Admin::RoutedQueryKeywordsController do; end
describe Admin::SiteFeedUrlsController do; end
describe Admin::SuggestionBlocksController do; end
describe Admin::UrlPrefixesController do; end
describe Admin::WatchersController do; end
