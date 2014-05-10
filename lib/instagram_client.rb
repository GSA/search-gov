module InstagramClient
  def self.instance
    @@client ||= begin
      Instagram.client(access_token: INSTAGRAM_ACCESS_TOKEN)
    end
  end
end
