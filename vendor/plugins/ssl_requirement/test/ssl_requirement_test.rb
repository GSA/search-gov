require 'rubygems'
require 'action_pack'
require 'action_controller'
require 'action_controller/test_process'
require 'test/unit'
begin; require 'redgreen'; rescue LoadError; end
$LOAD_PATH << 'lib'
require 'ssl_requirement'

ActionController::Base.logger = nil
ActionController::Routing::Routes.reload rescue nil

class SslRequirementController < ActionController::Base
  include SslRequirement
  
  ssl_required :a, :b
  ssl_allowed :c
  
  def a
    render :nothing => true
  end
  
  def b
    render :nothing => true
  end
  
  def c
    render :nothing => true
  end
  
  def d
    render :nothing => true
  end
  
  def set_flash
    flash[:foo] = "bar"
  end
end

class SslRequirementTest < ActionController::TestCase
  def setup
    @controller = SslRequirementController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  test "redirect to https preserves flash" do 
    get :set_flash
    get :b
    assert_response :redirect
    assert_equal "bar", flash[:foo]
  end

  test "not redirecting to https does preserve the flash" do
    get :set_flash
    get :d
    assert_response :success
    assert_equal "bar", flash[:foo]
  end

  test "redirect to http preserves flash" do
    get :set_flash
    @request.env['HTTPS'] = "on"
    get :d
    assert_response :redirect
    assert_equal "bar", flash[:foo]
  end

  test "not redirecting to http does preserve the flash" do
    get :set_flash
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
    assert_equal "bar", flash[:foo]
  end

  test "required without ssl" do
    assert_not_equal "on", @request.env["HTTPS"]
    get :a
    assert_response :redirect
    assert_match %r{^https://}, @response.headers['Location']
    get :b
    assert_response :redirect
    assert_match %r{^https://}, @response.headers['Location']
  end

  test "required with ssl" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
    get :b
    assert_response :success
  end

  test "disallowed without ssl" do
    assert_not_equal "on", @request.env["HTTPS"]
    get :d
    assert_response :success
  end

  test "disallowed with ssl" do
    @request.env['HTTPS'] = "on"
    get :d
    assert_response :redirect
    assert_match %r{^http://}, @response.headers['Location']
  end

  test "allowed without ssl" do
    assert_not_equal "on", @request.env["HTTPS"]
    get :c
    assert_response :success
  end

  test "allowed with ssl" do
    @request.env['HTTPS'] = "on"
    get :c
    assert_response :success
  end
end

class SslRequiredAllController < ActionController::Base
  include SslRequirement
  ssl_required

  def a
    render :nothing => true
  end
end


class SslRequiredAllTest < ActionController::TestCase
  def setup
    @controller = SslRequiredAllController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "allows ssl" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
  end

  test "disallowed without ssl" do
    get :a
    assert_response :redirect
  end
end


class SslAllowedAllController < ActionController::Base
  include SslRequirement
  ssl_allowed :all

  def a
    render :nothing => true
  end
end

class SslAllowedAllTest < ActionController::TestCase
  def setup
    @controller = SslAllowedAllController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "allows ssl" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
  end

  test "allowes without ssl" do
    get :a
    assert_response :success
  end
end


class SslAllowedAndRequiredController < ActionController::Base
  include SslRequirement
  ssl_allowed
  ssl_required

  def a
    render :nothing => true
  end
end

class SslAllowedAndRequiredTest < ActionController::TestCase
  def setup
    @controller = SslAllowedAndRequiredController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "allows ssl" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
  end

  test "diallowes without ssl" do
    get :a
    assert_response :redirect
  end
end

class SslAllowedAndRequiredController < ActionController::Base
  include SslRequirement
  ssl_required

  def a
    render :nothing => true
  end

  protected

  def ssl_host
    'www.xxx.com'
  end
end

class SslHostTest < ActionController::TestCase
  def setup
    @controller = SslAllowedAndRequiredController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "uses ssl_host" do
    @request.env['HTTPS'] = "on"
    get :a
    assert_response :success
  end

  test "diallowes without ssl" do
    get :a
    assert_response :redirect
    assert_match %r{^https://www.xxx.com/}, @response.headers['Location']
  end
end
