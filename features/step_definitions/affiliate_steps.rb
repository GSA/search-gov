Given /^the following( search consumer| SearchGov)? Affiliates exist:$/ do |affiliate_type, table|
  Affiliate.destroy_all
  table.hashes.each do |hash|
    valid_options = {
        email: hash[:contact_email],
        first_name: hash[:first_name],
        last_name: hash[:last_name],
        organization_name: 'Agency'
    }
    user = User.find_by_email(hash[:contact_email]) || User.create!( valid_options)
    user.update_attribute(:is_affiliate, true)
    user.update_attribute(:approval_status, 'approved')

    excluded_keys = %w[agency_abbreviation contact_email first_name last_name domains youtube_handles is_image_search_navigable]
    affiliate_attributes = hash.except *excluded_keys
    affiliate_attributes['search_consumer_search_enabled'] ||= (/search consumer/ === affiliate_type)
    affiliate_attributes['search_engine'] = 'SearchGov' if (/SearchGov/ === affiliate_type)
    affiliate = Affiliate.create! affiliate_attributes
    affiliate.image_search_label.navigation.update!(is_active: true) if hash[:is_image_search_navigable] == 'true'
    affiliate.users << user

    if hash[:agency_abbreviation].present?
      agency = Agency.find_by_abbreviation hash[:agency_abbreviation]
      affiliate.update!(agency: agency)
    end

    hash[:youtube_handles].split(',').each do |youtube_handle|
      profile = YoutubeProfile.where(channel_id: "#{youtube_handle}_channel_id",
                                     title: youtube_handle).first_or_initialize
      profile.save!(validate: false)
      affiliate.youtube_profiles << profile unless affiliate.youtube_profiles.exists?(id: profile.id)
      affiliate.rss_feeds.where(is_managed: true).first_or_create!(name: 'Videos')
    end if hash[:youtube_handles].present?

    hash[:domains].split(',').each { |domain| affiliate.site_domains.create!(domain: domain) } if hash[:domains].present?
  end
  ElasticNewsItem.recreate_index
end

Then /^I should see the code for (English|Spanish) language sites$/ do |locale|
  locales = { 'English' => 'en', 'Spanish' => 'es' }
  page.should have_selector("#embed_code_textarea_#{locales[locale]}")
end

Then /^the "([^"]*)" field should be disabled$/ do |label|
  field_labeled(label)['disabled'].should == 'disabled'
end

Given /^the following Connections exist for the affiliate "([^"]*)":$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each do |hash|
    connected_affiliate = Affiliate.find_by_name(hash[:connected_affiliate])
    affiliate.connections.create!(connected_affiliate: connected_affiliate, label: hash[:display_name])
  end
end

Given /^the following SystemAlerts exist:$/ do |table|
  table.hashes.each do |hash|
    start_at = case hash[:start_at]
                 when 'today'
                   DateTime.current
                 when /^[[:alpha:]]/
                   DateTime.current.send(hash[:start_at].gsub(/\s+/, '_').to_sym)
                 else nil
               end
    end_at = case hash[:end_at]
               when 'today'
                 DateTime.current
               when /^[[:alpha:]]/
                 DateTime.current.send(hash[:end_at].gsub(/\s+/, '_').to_sym)
               else nil
             end
    SystemAlert.create!(:message => hash[:message],
                        :start_at => start_at,
                        :end_at => end_at)
  end
end

When /^the Affiliate "(.*?)" has the following users:$/ do |name, table|
  affiliate = Affiliate.find_by_name name
  table.hashes.each do |hash|
    user = User.find_by_email hash[:email]
    affiliate.memberships.create!(user: user)
  end
end

When /^the rss govbox is enabled for the site "(.*?)"$/ do |name|
  site = Affiliate.find_by_name name
  site.update!(is_rss_govbox_enabled: true)
end

Given(/^"(.*?)" is an affiliate$/) do |email|
  User.find_by_email(email).update_attribute(:is_affiliate, true)
end

Given /^the following "(.+)" exist for the affiliate (.+):$/ do |association, affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  association.gsub!(' ','_')
  table.hashes.each {|hash|  affiliate.send(association).create!(hash) }
end
