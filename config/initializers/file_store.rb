require 'active_support/cache/file_store'

# TODO: Remove this after upgrading to Rails 4.x
#
# https://www.pivotaltracker.com/story/show/46132261
# https://github.com/rails/rails/pull/4911
ActiveSupport::Cache::FileStore.send(:remove_const, "FILENAME_MAX_SIZE")
ActiveSupport::Cache::FileStore.const_set("FILENAME_MAX_SIZE", 228)
