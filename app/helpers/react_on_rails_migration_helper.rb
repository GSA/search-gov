# frozen_string_literal: true

require 'delegate'
require 'react'

module ReactOnRailsMigrationHelper
  class ViewProxy < SimpleDelegator
    include ReactOnRails::Helper
  end

  def react_on_rails_component(component_name, props: {}, html_options: {}, prerender: false, **options)
    react_on_rails_options = options.merge(
      props: react_on_rails_props(props),
      prerender:,
      html_options:
    )

    ViewProxy.new(self).react_component(component_name, react_on_rails_options)
  end

  private

  def react_on_rails_props(props)
    return props unless Rails.application.config.react.camelize_props

    React.camelize_props(props)
  end
end
