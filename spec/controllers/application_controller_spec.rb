require 'spec_helper'

# An example controller for testing various things.
class ExampleController < ApplicationController
  def missing_template
    respond_to do |format|
      format.html{ render :text => 'Hello, World!' }
      format.any
    end
  end
end

# draw the route for the example controller

describe ExampleController do
  render_views
  before do
    routes = Rails.application.routes
    routes.draw do
      resources :example, :only => [:index] do
        collection do
          get :missing_template
        end
      end
    end
    ActiveSupport.on_load(:action_controller) { routes.finalize! }
  end

  after do
    Rails.application.reload_routes!
  end

  context 'when the format for the request is not a valid format' do
    it 'responds with a 204' do
      get :missing_template, format: 'orig'
      expect(response.code).to eq('204')
    end
  end

  describe '#handle_unverified_request' do
    it 'raises an error' do
      expect { ExampleController.new.handle_unverified_request }.to raise_error(ActionController::InvalidAuthenticityToken)
    end
  end
end
