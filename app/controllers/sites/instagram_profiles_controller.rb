class Sites::InstagramProfilesController < Sites::SetupSiteController
  include Sites::ScaffoldProfilesController

  # Not used: see https://www.pivotaltracker.com/story/show/154784908
  # self.adapter_klass = InstagramData
  self.primary_attribute_name = :username
end
