class ClicksController < ApplicationController
  def create
    click_json = Rails.cache.read(params[:key])
    if click_json.nil?
      RAILS_DEFAULT_LOGGER.warn "Couldn't find cached search info for key: #{params[:key]}"
      redirect_to home_page_path
      return
    end
    click = Click.new.from_json(click_json)
    click.clicked_at = DateTime.now
    click.save!
    redirect_to click.url
  end
end

