require 'sortable'
ActionController::Base.send(:include, Sortable)

VIEW_PATH = File.join(RAILS_ROOT, 'vendor', 'plugins', 'sortable', 'views')
ActionController::Base.append_view_path(VIEW_PATH) unless ActionController::Base.view_paths.include?(VIEW_PATH)

require 'sortable_helper'
ActionView::Base.send(:include, SortableHelper)

if RAILS_ENV == 'test'
  # only load the example files/routes in development mode
  # TODO easy way to load all controller/model paths instead? Don't know off the top of my head but am sure it's easy
  require File.join(File.dirname(__FILE__), 'example', 'controllers', 'cablecar', 'users_controller')
  require File.join(File.dirname(__FILE__), 'example', 'models', 'cablecar', 'user')
  require File.join(File.dirname(__FILE__), 'example', 'models', 'cablecar', 'contact_info')

  # install the routes
  require File.join(File.dirname(__FILE__), 'test', 'example_test_routing')
  
  # install the example app view path
  VIEW_PATH = File.join(RAILS_ROOT, 'vendor', 'plugins', 'sortable', 'example', 'views')
  ActionController::Base.append_view_path(VIEW_PATH) unless ActionController::Base.view_paths.include?(VIEW_PATH)
end

COPY_IMAGES = true

if COPY_IMAGES
  require "ftools"

  File.copy(File.join(File.dirname(__FILE__), 'images', 'logo_opaque.png'), File.join(RAILS_ROOT, 'public', 'images'))
  File.copy(File.join(File.dirname(__FILE__), 'images', 'arrow_up.gif'), File.join(RAILS_ROOT, 'public', 'images'))
  File.copy(File.join(File.dirname(__FILE__), 'images', 'arrow_down.gif'), File.join(RAILS_ROOT, 'public', 'images'))
end