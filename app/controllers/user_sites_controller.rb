# frozen_string_literal: true

class UserSitesController < ApplicationController
  layout 'sites'
  before_action :set_user

  def index
    @affiliates = @user.affiliates.paginate(page: params[:page], per_page: 100)
  
    respond_to do |format|
      format.html
      format.csv { send_data generate_csv, filename: "affiliates-#{Date.today}.csv", type: 'text/csv' }
    end
  end

  private

  def set_user
    @user = @current_user.presence || current_user
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[id display_name site_handle admin_home_page homepage_url site_search_page]

      @affiliates.each do |affiliate|
        csv << [affiliate.id, affiliate.display_name, affiliate.name, site_path(affiliate), affiliate.website, search_path(affiliate: affiliate.name).to_s]
      end
    end
  end
end
