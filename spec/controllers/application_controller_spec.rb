require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# An example controller for testing various things.
class ExampleController < ApplicationController 
  def missing_template
    respond_to do |format|
      format.html{ render :text => 'Hello, World!'}
      format.any
    end
  end  
end

# draw the route for he example controller
ActionController::Routing::Routes.draw do |map|
  map.resources :example, :only => [:index], :collection => [:missing_template]
end

describe ExampleController do
  integrate_views
  
  context "when a request raises an ActionView::MissingTemplate error" do
    context "when the format for the request is a valid format" do
      it "should raise an error" do
        lambda {get :missing_template, :format => 'json'}.should raise_error(ActionView::MissingTemplate)
      end
    end
    
    context "when the format for the request is not a valid format" do
      it "should render a 404" do
        get :missing_template, :format => "orig"
        response.should contain(/The page you were looking for doesn't exist/)
      end
    end
  end  
end