require File.dirname(__FILE__) + '/abstract_unit'

class CallersController < ActionController::Base
  def calling_from_controller
    render_component(:controller => "callees", :action => "being_called")
  end

  def calling_from_controller_with_params
    render_component(:controller => "callees", :action => "being_called", :params => { "name" => "David" })
  end
  
  def calling_from_controller_with_session
    session['name'] = 'Bernd'
    render_component(:controller => "callees", :action => "being_called")
  end

  def calling_from_controller_with_different_status_code
    render_component(:controller => "callees", :action => "blowing_up")
  end

  def calling_from_template
    render :inline => "Ring, ring: <%= render_component(:controller => 'callees', :action => 'being_called') %>"
  end

  def internal_caller
    render :inline => "Are you there? <%= render_component(:action => 'internal_callee') %>"
  end

  def internal_callee
    render :text => "Yes, ma'am"
  end

  def set_flash
    render_component(:controller => "callees", :action => "set_flash")
  end

  def use_flash
    render_component(:controller => "callees", :action => "use_flash")
  end

  def calling_redirected
    render_component(:controller => "callees", :action => "redirected")
  end

  def calling_redirected_as_string
    render :inline => "<%= render_component(:controller => 'callees', :action => 'redirected') %>"
  end

  def rescue_action(e) raise end
end

class ChildCallersController < CallersController
end

class CalleesController < ActionController::Base
  def being_called
    render :text => "#{params[:name] || session[:name] || "Lady"} of the House, speaking"
  end

  def blowing_up
    render :text => "It's game over, man, just game over, man!", :status => 500
  end

  def set_flash
    flash[:notice] = 'My stoney baby'
    render :text => 'flash is set'
  end

  def use_flash
    render :text => flash[:notice] || 'no flash'
  end

  def redirected
    redirect_to :controller => "callees", :action => "being_called"
  end

  def rescue_action(e) raise end
end

class ComponentsTest < ActionController::IntegrationTest #ActionController::TestCase
  
  def setup
    @routes.draw do 
      match 'callers/:action', :to => 'callers'
      match 'child_callers/:action', :to => 'child_callers'
      match 'callees/:action', :to => 'callees'
    end
  end
  
  def test_calling_from_controller
    get '/callers/calling_from_controller'
    assert_equal "Lady of the House, speaking", @response.body
  end

  def test_calling_from_controller_with_params
    get '/callers/calling_from_controller_with_params'
    assert_equal "David of the House, speaking", @response.body
  end

  def test_calling_from_controller_with_different_status_code
    get '/callers/calling_from_controller_with_different_status_code'
    assert_equal 500, @response.response_code
  end
 
  def test_calling_from_template
    get '/callers/calling_from_template'
    assert_equal "Ring, ring: Lady of the House, speaking", @response.body
  end

  def test_etag_is_set_for_parent_template_when_calling_from_template
    get '/callers/calling_from_template'
    expected_etag = etag_for("Ring, ring: Lady of the House, speaking")
    assert_equal expected_etag, @response.headers['ETag']
  end

  def test_internal_calling
    get '/callers/internal_caller'
    assert_equal "Are you there? Yes, ma'am", @response.body
  end

  def test_flash
    get '/callers/set_flash'
    assert_equal 'My stoney baby', flash[:notice]
    get '/callers/use_flash'
    assert_equal 'My stoney baby', @response.body
    get '/callers/use_flash'
    assert_equal 'no flash', @response.body
  end

  def test_component_redirect_redirects
    get '/callers/calling_redirected'
    assert_redirected_to :controller=>"callees", :action => "being_called"
  end


  def test_component_multiple_redirect_redirects
    test_component_redirect_redirects
    test_internal_calling
  end


  def test_component_as_string_redirect_renders_redirected_action
    get '/callers/calling_redirected_as_string'

    assert_equal "Lady of the House, speaking", @response.body
  end
  
  def test_calling_from_controller_with_session
    get '/callers/calling_from_controller_with_session'
    assert_equal "Bernd of the House, speaking", @response.body
  end

  def test_child_calling_from_template
    get '/child_callers/calling_from_template'
    assert_equal "Ring, ring: Lady of the House, speaking", @response.body
  end
  
  


  protected
    def etag_for(text)
      %("#{Digest::MD5.hexdigest(text)}")
    end
end
