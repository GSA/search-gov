module BingV6Authentication
  APP_ID = Rails.application.secrets.bing_v6['app_id'].freeze

  def params
    super.merge({
      AppId: APP_ID
    })
  end
end
