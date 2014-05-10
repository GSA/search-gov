class Sites::InstagramProfilesController < Sites::SetupSiteController
  include Sites::ScaffoldProfilesController

  self.adapter_klass = InstagramData
  self.primary_attribute_name = :username
end
