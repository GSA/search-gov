module InstagramData
  def self.import_profile(user)
    InstagramProfile.where(id: user.id).first_or_create!(username: user.username)
  end

  def self.find_user(username)
    return unless username.present?
    normalized_username = username.squish.downcase
    users = InstagramClient.instance.user_search(normalized_username)
    users.find { |user| user.username == normalized_username }
  end
end
