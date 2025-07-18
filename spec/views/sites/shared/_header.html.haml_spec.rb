require 'spec_helper'

module ApplicationHelper
  def current_user
    User.new
  end
end

describe 'sites/shared/_header' do
  before { @site = double('Site', active?: true) }

  it_behaves_like 'a non-prod git info banner'
end
