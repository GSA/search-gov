require 'render_component/components'
require 'action_controller'
require 'action_dispatch/middleware/flash'
ActionController::Base.send :include, RenderComponent::Components
