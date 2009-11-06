require File.dirname(__FILE__) + '/test_helper'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_sortable_db
  old_stdout = $stdout
  
  # AR keeps printing annoying schema statements
  $stdout = StringIO.new

  ActiveRecord::Base.logger
  ActiveRecord::Schema.define(:version => 1) do
    create_table :cablecar_users do |t|
      t.column :username, :string
      t.column :status, :string
      t.column :contact_info_id, :integer
    end

    create_table :cablecar_contact_infos do |t|
      t.column :name, :string
      t.column :phone, :string
    end
  end
  
  $stdout = old_stdout
end

setup_sortable_db

require File.dirname(__FILE__) + '/../example/controllers/cablecar/users_controller'

# Re-raise errors caught by the controller.
class Cablecar::UsersController
  def rescue_action(e) raise e end
end


class UsersControllerTest < Test::Unit::TestCase

  def teardown_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  #fixtures :widgets

  def setup
    @controller = Cablecar::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    30.times do |n|
      c = Cablecar::ContactInfo.new(:name => "name#{n}")
      c.user = Cablecar::User.new(:username => "user#{n}")
      c.save!
    end
  end

  def teardown
    teardown_db
  end

  def test_should_show_paginated_table_using_default_action
    get :index, :use_default => true
    assert_equal 10, assigns(:objects).size    

    verify_sortable_table_html
    verify_pagination_html
  end

  def test_should_show_paginated_table
    get :index
    assert_equal 10, assigns(:objects).size    

    verify_sortable_table_html
    verify_pagination_html
  end
  
  def test_should_show_sorable_table_without_pagination
    get :index, :no_pagination => true
    assert_equal 10, assigns(:objects).size    

    verify_sortable_table_html
    assert_select 'div.pagination', false
  end

  def test_should_show_paginated_table_with_overrides_and_related_columns
    get :index, :complex_example => true
    assert_equal 15, assigns(:objects).size    
    assert_select 'thead' do
      assert_select 'tr' do
        assert_select 'td', :count => 3
        assert_select 'td.sortdown', 'Name'
        assert_select 'td.sortdown' do 
          assert_select 'a[href=/cablecar/users?sort=name]', 'Name'
          assert_select 'a[title=Sort by this field]', 'Name'
        end
      end
    end
    assert_select 'tbody' do
      assert_select 'tr', :count => 15
      verify_name_user_row_data(11, 22)
    end    
    verify_pagination_html(2)
  end

  def test_should_sortdown_up_by_related_field
    get :index, :sort => 'name', :complex_example => true
    assert_equal 15, assigns(:objects).size    
    assert_select 'thead' do
      assert_select 'tr' do
        assert_select 'td', :count => 3
        assert_select 'td.sortup', 'Name'
        assert_select 'td.sortup' do 
          assert_select 'a[href=/cablecar/users?sort=name_reverse]', 'Name'
          assert_select 'a[title=Sort by this field]', 'Name'
        end
      end
    end
    assert_select 'tbody' do
      assert_select 'tr', :count => 15
      verify_name_user_row_data(4, 10)
      verify_name_user_row_data(23, 30)
    end    
    verify_pagination_html(2)
  end

  def test_should_sortup_up_by_field_with_desc_default_sort
    get :index, :sort => 'name_reverse', :complex_example => true
    assert_equal 15, assigns(:objects).size    
    assert_select 'thead' do
      assert_select 'tr' do
        assert_select 'td', :count => 3
        assert_select 'td.sortdown', 'Name'
        assert_select 'td.sortdown' do 
          assert_select 'a[href=/cablecar/users?sort=name]', 'Name'
          assert_select 'a[title=Sort by this field]', 'Name'
        end
      end
    end
    assert_select 'tbody' do
      assert_select 'tr', :count => 15
      verify_name_user_row_data(11, 22)
    end    
    verify_pagination_html(2)
  end

  def test_should_sortup_up_by_field_with_asc_default_sort
    get :index, :sort => 'status_reverse', :complex_example => true
    assert_equal 15, assigns(:objects).size    
    assert_select 'thead' do
      assert_select 'tr' do
        assert_select 'td', :count => 3
        assert_select 'td.sortdown', 'Status'
        assert_select 'td.sortdown' do 
          assert_select 'a[href=/cablecar/users?sort=status]', 'Status'
          assert_select 'a[title=Sort by this field]', 'Status'
        end
      end
    end
    assert_select 'tbody' do
      assert_select 'tr', :count => 15
      verify_name_user_row_data(1, 15)
    end    
    verify_pagination_html(2)
  end

  def test_should_sortup_up_by_field_with_more_than_one_sort_param
    get :index, :sort => 'username_reverse', :complex_example => true
    assert_equal 15, assigns(:objects).size    
    assert_select 'thead' do
      assert_select 'tr' do
        assert_select 'td', :count => 3
        assert_select 'td.sortdown', 'Username'
        assert_select 'td.sortdown' do 
          assert_select 'a[href=/cablecar/users?sort=username]', 'Username'
          assert_select 'a[title=Sort by this field]', 'Username'
        end
      end
    end
    assert_select 'tbody' do
      assert_select 'tr', :count => 15
      verify_name_user_row_data(1, 15)
    end    
    verify_pagination_html(2)
  end

  def test_should_fail_to_sort_with_invalid_sort_param
    assert_raise Exception do |ex|
      get :index, :sort => 'username_invalid', :complex_example => true
    end
  end
  
  def test_should_override_class_defaults
    Cablecar::UsersController.class_eval do
      sortable_table Cablecar::User, {:include_relations => [:contact_info],
                               :table_headings => [['Username', 'username'], ['Status', 'status'], ['Name', 'name']],
                               :sort_map => {:username => [['cablecar_users.username', 'DESC'], ['cablecar_users.status', 'DESC']], 
                                             :status => ['cablecar_users.status', 'ASC'],
                                             :name => ['cablecar_contact_infos.name', 'DESC']},
                               :default_sort => ['name', 'ASC'],
                               :per_page => 15}
    end  
    get :index, :sort => 'name_reverse'
    assert_equal 15, assigns(:objects).size    
    assert_select 'thead' do
      assert_select 'tr' do
        assert_select 'td', :count => 3
        assert_select 'td.sortdown', 'Name'
        assert_select 'td.sortdown' do 
          assert_select 'a[href=/cablecar/users?sort=name]', 'Name'
          assert_select 'a[title=Sort by this field]', 'Name'
        end
      end
    end
    assert_select 'tbody' do
      assert_select 'tr', :count => 15
      verify_name_user_row_data(11, 22)
    end    
    verify_pagination_html(2)

    Cablecar::UsersController.class_eval do
      sortable_table Cablecar::User # put things back where you found them
    end
  end
  
  def verify_name_user_row_data(start, finish)
    start.upto(finish) do |n|
      assert_select "tr#cablecar_user_#{n}" do
        assert_select 'td', :count => 3
        assert_select 'td', {:minimum => 1}, "name#{n}" # test that the name value is there
        assert_select 'td', {:minimum => 1}, "user#{n}"
      end      
    end
  end
  
  def verify_sortable_table_html(count=10)
    verify_sortable_table_header
    assert_select 'tbody' do
      assert_select 'tr', :count => count
      30.downto(21) do |n|
        assert_select "tr#cablecar_user_#{n}" do
          assert_select 'td', :count => 4
          assert_select 'td', {:minimum => 1}, n # test that the id value is there
        end
      end
    end    
  end
  
  def verify_sortable_table_header(href='/cablecar/users?sort=id_reverse')
    assert_select 'thead' do
      assert_select 'tr' do
        assert_select 'td', :count => 4
        assert_select 'td.sortup', 'Id'
        assert_select 'td.sortup' do 
          assert_select "a[href=#{href}]", 'Id'
          assert_select 'a[title=Sort by this field]', 'Id'
        end
      end
    end    
  end
  
  def verify_pagination_html(pages=3)
    assert_select 'div.pagination' do 
      assert_select 'span', :count => 2
      assert_select 'a', :count => pages
    end    
  end

  def test_truth
    true
  end
  
  def test_should_search
    get :index, :q => 'user3'
    assert_equal 1, assigns(:objects).size    

    verify_sortable_table_header('/cablecar/users?q=user3&amp;sort=id_reverse')
    
    assert_select 'tbody' do
      assert_select 'tr', :count => 1
        assert_select "tr#cablecar_user_4" do
          assert_select 'td', :count => 4
          assert_select 'td', {:minimum => 1}, 4 # test that the id value is there
        end
    end    
  end

  def test_should_search_and_return_multiple_results
    get :index, :q => 'user4'
    assert_equal 2, assigns(:objects).size    

    verify_sortable_table_header('/cablecar/users?q=user4&amp;sort=id_reverse')
    assert_select 'tbody' do
      assert_select 'tr', :count => 2
        assert_select "tr#cablecar_user_5" do
          assert_select 'td', :count => 4
          assert_select 'td', {:minimum => 1}, 4 # test that the id value is there
        end
    end    

  end
      
  def create_a_dupe_user
    c = Cablecar::ContactInfo.new(:name => "dupe_name4")
    c.user = Cablecar::User.new(:username => "dupe_user4")
    c.user.status = 'active'
    c.save!    
  end
  
  def test_should_search_and_filter_results
    create_a_dupe_user
    # This tests the ability to search as well as apply an additional filter that is used in conjunction with the
    # search conditions
    get :index, :q => 'user4', :active => 'true', :filter_example => true
    assert_equal 1, assigns(:objects).size    

    verify_sortable_table_header('/cablecar/users?q=user4&amp;sort=id_reverse')
    assert_select 'tbody' do
      assert_select 'tr', :count => 1
        assert_select "tr#cablecar_user_31" do
          assert_select 'td', :count => 4
          assert_select 'td', {:minimum => 1}, 4 # test that the id value is there
        end
    end    
    
  end
  
  def test_should_search_and_return_multiple_results
    create_a_dupe_user

    get :index, :q => 'user4'
    assert_equal 2, assigns(:objects).size    

    verify_sortable_table_header('/cablecar/users?q=user4&amp;sort=id_reverse')
    assert_select 'tbody' do
      assert_select 'tr', :count => 2
        assert_select "tr#cablecar_user_5" do
          assert_select 'td', :count => 4
          assert_select 'td', {:minimum => 1}, 4 # test that the id value is there
        end
    end    

  end
  
end