Feature: Manage Display
  Scenario: Editing Sidebar Settings on a new site
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | is_bing_image_search_enabled |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | true                         |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Display page
    Then I should see "Image Search Label 0"
    And I should not see "Results Format"

    When affiliate "agency.gov" has the following RSS feeds:
      | name   | url                    | show_only_media_content | position | oasis_mrss_name |
      | Photos | www.dma.mil/photos.xml | true                    | 101      | 1               |
    And I go to the agency.gov's Manage Display page
    Then I should see "Image Search Label 0"
    And I should not see "Rss Feed 1"

    When affiliate "agency.gov" has the following RSS feeds:
      | name   | url                    | show_only_media_content | position |
      | Photos | www.dma.mil/photos.xml | false                   | 101      |
    And the following flickr URLs exist for the site "agency.gov":
      | url                                      | profile_type | profile_id   |
      | http://www.flickr.com/photos/whitehouse/ | user         | 35591378@N03 |
    And I go to the agency.gov's Manage Display page
    Then I should see "Image Search Label 0"
    And I should see "Rss Feed 1"

    When the following Affiliates exist:
      | display_name | name             | contact_email   | first_name | last_name | is_bing_image_search_enabled |
      | agency site  | bingimageenabled | john@agency.gov | John       | Bar       | true                         |
    And affiliate "bingimageenabled" has the following RSS feeds:
      | name  | url                 | show_only_media_content | position | oasis_mrss_name |
      | Media | photos.gov/all.atom | true                    | 200      | 100             |
    And I go to the bingimageenabled's Manage Display page
    Then I should see "Image Search Label 0"
    And I should see "Domains/MRSS"
    And I should not see "Rss Feed 1"

    When the following Affiliates exist:
      | display_name | name                | contact_email   | first_name | last_name | is_bing_image_search_enabled |
      | agency site  | bing-image-disabled | john@agency.gov | John       | Bar       | false                        |
    And affiliate "bing-image-disabled" has the following RSS feeds:
      | name   | url                 | show_only_media_content | position | oasis_mrss_name |
      | Photos | photos.gov/all.atom | true                    | 200      | 100             |
    And I go to the bing-image-disabled's Manage Display page
    Then I should see "Image Search Label 0"
    And I should not see "Domains/MRSS"
    And I should not see "Rss Feed 1"
    When I follow "MRSS"
    Then I should see "Photos"

  @javascript
  Scenario: Editing GovBoxes Settings
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | agency_abbreviation | gets_i14y_results |
      | agency site  | agency.gov | john@agency.gov | John       |Bar        | DOC                 | true              |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes         |
      | Blog | agency.gov/blog/ |
    And affiliate "agency.gov" has the following RSS feeds:
      | name  | url                                                                  | show_only_media_content |
      | Press | search.gov/all.atom                                                  | false                   |
      | DMA   | media.dma.mil/mrss/portal/144/detailpage/www.af.mil/News/Photos.aspx | true                    |
    And the following flickr URLs exist for the site "agency.gov":
      | url                                      | profile_type | profile_id   |
      | http://www.flickr.com/photos/whitehouse/ | user         | 35591378@N03 |
    And the following YouTube channels exist for the site "agency.gov":
      | channel_id              | title        |
      | usgovernment_channel_id | USGovernment |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Display page
    And the "Rss govbox label" field should contain "News"
    And the "Is rss govbox enabled" should be switched off
    And the "Is video govbox enabled" should be switched on
    And the "Jobs enabled" should be switched off
    And the "Is federal register document govbox enabled" should be switched off
    And the "Is related searches enabled" should be switched on
    And the "Is sayt enabled" should be switched on
    And the "Is medline govbox enabled" should be switched off
    And the "i14y date stamp enabled" should be switched off

    When I fill in "Rss govbox label" with "Latest News"
    And I switch on "Is rss govbox enabled"
    And I switch off "Is video govbox enabled"
    And I switch on "Jobs enabled"
    And I switch on "Is federal register document govbox enabled"
    And I switch off "Is related searches enabled"
    And I switch on "Is medline govbox enabled"
    And I switch off "Is sayt enabled"
    And I switch on "i14y date stamp enabled"

    And I submit the form by pressing "Save"
    Then I should see "You have updated your site display settings"
    And the "Rss govbox label" field should contain "Latest News"
    And the "Is rss govbox enabled" should be switched on
    And the "Is video govbox enabled" should be switched off
    And the "Jobs enabled" should be switched on
    And the "Is federal register document govbox enabled" should be switched on
    And the "Is related searches enabled" should be switched off
    And the "Is medline govbox enabled" should be switched on
    And the "Is sayt enabled" should be switched off
    And the "i14y date stamp enabled" should be switched on

  @javascript
  Scenario: Editing Related Sites
    Given the following Affiliates exist:
      | display_name  | name         | contact_email   | first_name | last_name |
      | agency site 1 | 1.agency.gov | john@agency.gov | John       | Bar       |
      | agency site 2 | 2.agency.gov | john@agency.gov | John       | Bar       |
      | agency site 3 | 3.agency.gov | john@agency.gov | John       | Bar       |
    And I am logged in with email "john@agency.gov"
    When I go to the 1.agency.gov's Manage Display page
    And I fill in the following:
      | Connection site handle 0 | 2.agency.gov       |
      | Connection label 0       | agency site 2 SERP |
    When I follow "Add Another Related Site"
    Then I should be able to access 2 related site entries
    When I fill in the following:
      | Connection site handle 1 | 3.agency.gov       |
      | Connection label 1       | agency site 3 SERP |
    And I submit the form by pressing "Save"
    Then I should see "You have updated your site display settings"
    And the "Connection site handle 0" field should contain "2.agency.gov"
    And the "Connection label 0" field should contain "agency site 2 SERP"
    And the "Connection site handle 1" field should contain "3.agency.gov"
    And the "Connection label 1" field should contain "agency site 3 SERP"

    And I fill in the following:
      | Connection site handle 0 | |
      | Connection label 0       | |
    And I submit the form by pressing "Save"
    Then I should see "You have updated your site display settings"
    And the "Connection site handle 0" field should contain "3.agency.gov"
    And the "Connection label 0" field should contain "agency site 3 SERP"

  @javascript
  Scenario: Editing Font & Colors on Affiliate
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Font & Colors page
    Then the "Font Family" field should contain "Default"
    And the "Default" radio button should be checked

    When I select "Helvetica, sans-serif" from "Font Family"
    And I choose "Custom"
    And I fill in the following:
      | Page Background Color       | #000001 |
      | Button Background Color     | #000020 |
      | Header Background Color     | #000300 |
      | Footer Background Color     | #004000 |
      | Navigation Background Color | #050000 |
      | Active Navigation Color     | #600000 |
      | Navigation Link Color       | #000007 |
      | Link Color                  | #A00000 |
      | Visited Link Color          | #0B0000 |
      | Result URL Color            | #00C000 |
      | Description Text Color      | #000D00 |
    And I submit the form by pressing "Save"

    Then I should see "You have updated your font & colors"
    And the "Font Family" field should contain "Helvetica, sans-serif"
    And the "Custom" radio button should be checked
    And the "Page Background Color" field should contain "#000001"
    And the "Button Background Color" field should contain "#000020"
    And the "Header Background Color" field should contain "#000300"
    And the "Footer Background Color" field should contain "#004000"
    And the "Navigation Background Color" field should contain "#050000"
    And the "Active Navigation Color" field should contain "#600000"
    And the "Navigation Link Color" field should contain "#000007"
    And the "Link Color" field should contain "#A00000"
    And the "Visited Link Color" field should contain "#0B0000"
    And the "Result URL Color" field should contain "#00C000"
    And the "Description Text Color" field should contain "#000D00"

  @javascript
  Scenario: Editing Image Assets
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name |  website                |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       |  http://main.agency.gov |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Image Assets page
    And I fill in "Favicon URL" with "https://d3qcdigd1fhos0.cloudfront.net/blog/img/favicon.ico"
    And I attach the file "features/support/logo_mobile_en.png" to "Logo"
    And I select "left" from "Logo Alignment"
    When I fill in "Logo Alt Text" with "  Awesome   Agency  "
    And I submit the form by pressing "Save"
    Then I should see "You have updated your image assets"
    And the "Favicon URL" field should contain "https://d3qcdigd1fhos0.cloudfront.net/blog/img/favicon.ico"
    And I should see an image with alt text "Logo"
    And the "Logo Alignment" field should contain "left"
    And the "Logo Alt Text" field should contain "Awesome Agency"

    When I am on agency.gov's search page
    Then I should see an image link to "Awesome Agency" with url for "http://main.agency.gov"
    And the page body should contain "logo_mobile_en.png"
    And I should see a left aligned SERP logo

    When I go to the agency.gov's Image Assets page
    And I select "right" from "Logo Alignment"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your image assets"

    When I am on agency.gov's search page
    Then I should see an image link to "Awesome Agency" with url for "http://main.agency.gov"
    And the page body should contain "logo_mobile_en.png"
    And I should see a right aligned SERP logo

    When I go to the agency.gov's Image Assets page
    And I check "Mark Logo for Deletion"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your image assets"
    And I should not see an image with alt text "Logo"

  @javascript
  Scenario: Editing Header & Footer
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | footer_fragment                   |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | <strong>my HTML fragment</strong> |
    And affiliate "agency.gov" has the following document collections:
      | name                 | prefixes             | position | is_navigable |
      | Active site search   | http://apps.usa.gov/ | 3        | true         |
      | Inactive site search | http://apps.usa.gov/ | 6        | false        |
    And affiliate "agency.gov" has the following RSS feeds:
      | name                 | url                            | is_navigable | position | show_only_media_content |
      | Inactive news search | http://en.agency.gov/feed/News | false        | 5        | false                   |
    And I am logged in with email "john@agency.gov"

    When I am on agency.gov's search page
    Then I should not see "Browse site"

    When I go to the agency.gov's Header & Footer page
    And I fill in the following:
      | Header Tagline      | Office website of the Awesome Agency |
      | Header Tagline URL  | http://awesomeagency.gov             |
      | Header Link Title 0 | News                                 |
      | Header Link URL 0   | news.agency.gov                      |
      | Footer Link Title 0 | Contact                              |
      | Footer Link URL 0   | mailto:contact@agency.gov            |

    And I attach the file "features/support/mini_logo.png" to "Header Tagline Logo"

    And I select "left" from "Menu Button Alignment"
    When I follow "Add Another Header Link"
    Then I should be able to access 2 header link rows
    When I fill in the following:
      | Header Link Title 1 | Blog            |
      | Header Link URL 1   | blog.agency.gov |
    When I follow "Add Another Footer Link"
    Then I should be able to access 2 footer link rows
    When I fill in the following:
      | Footer Link Title 1 | Terms of Service |
      | Footer Link URL 1   | tos.agency.gov   |
    And I submit the form by pressing "Save"

    Then I should see "You have updated your header and footer information"
    And the "Header Tagline" field should contain "Office website of the Awesome Agency"

    And the "Header Tagline URL" field should contain "http://awesomeagency.gov"
    And I should see an image with alt text "Header Tagline Logo"
    And the "Menu Button Alignment" field should contain "left"
    And the "Header Link Title 0" field should contain "News"
    And the "Header Link URL 0" field should contain "http://news.agency.gov"
    And the "Header Link Title 1" field should contain "Blog"
    And the "Header Link URL 1" field should contain "http://blog.agency.gov"
    And the "Footer Link Title 0" field should contain "Contact"
    And the "Footer Link URL 0" field should contain "mailto:contact@agency.gov"
    And the "Footer Link Title 1" field should contain "Terms"
    And the "Footer Link URL 1" field should contain "http://tos.agency.gov"

    When I am on agency.gov's search page
    Then I should see a link to "Contact" with url for "mailto:contact@agency.gov"
    And I should see a link to "Terms of Service" with url for "http://tos.agency.gov"
    And the page body should contain "mini_logo.png"
    And I should see "Office website of the Awesome Agency"
    And I should see a left aligned menu button
    And I should see "my HTML fragment" within the footer
    And I should not see "strong" within the footer

    When I press "Browse site"
    Then I should find "News" in the main menu
    Then I should see a link to "News" with url for "http://news.agency.gov"
    Then I should see a link to "Blog" with url for "http://blog.agency.gov"
    Then I should see a link to "Contact" with url for "mailto:contact@agency.gov"
    Then I should see a link to "Terms of Service" with url for "http://tos.agency.gov"

    When I am on agency.gov's "Inactive site search" docs search page
    And I press "Browse site"
    Then I should find "News" in the main menu
    Then I should see a link to "News" with url for "http://news.agency.gov"
    Then I should see a link to "Blog" with url for "http://blog.agency.gov"

    When I am on agency.gov's "Inactive news search" news search page
    And I press "Browse site"
    Then I should find "News" in the main menu
    Then I should see a link to "News" with url for "http://news.agency.gov"
    Then I should see a link to "Blog" with url for "http://blog.agency.gov"

    When I go to the agency.gov's Header & Footer page
    And I check "Mark Header Tagline Logo for Deletion"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your header and footer information"
    And I should not see an image with alt text "Header Tagline Logo"

    When I attach the file "features/support/bg.png" to "Header Tagline Logo"
    And I submit the form by pressing "Save"
    Then I should see "Header tagline logo file size must be under 16 KB"
    And I should not see an image with alt text "Header Tagline Logo"

  @javascript
  Scenario: Error when Editing Header & Footer
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name   | last_name |
      | agency site  | agency.gov | john@agency.gov | John         | Bar       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Header & Footer page
    And I fill in the following:
      | Header Link Title 0 | News               |
      | Footer Link URL 0   | contact.agency.gov |
    And I submit the form by pressing "Save"
    Then I should see "Header link URL can't be blank"
    Then I should see "Footer link title can't be blank"

    @javascript
    Scenario: Editing No Results Page
      Given the following Affiliates exist:
        | display_name | name       | contact_email   | first_name   | last_name | website                    |
        | agency site  | agency.gov | john@agency.gov | John         | Bar       | http://main.agency.gov     |
      And I am logged in with email "john@agency.gov"
      When I go to the agency.gov's No Results Page page

      And I fill in "Additional Guidance Text" with "The GSA apologizes for not having any relevant results."
      And I submit the form by pressing "Save"

      Then I should see "You have updated your No Results Page"
      And the "Additional Guidance Text" field should contain "The GSA apologizes for not having any relevant results."

      When I follow "Add Another Alternative Link"
      Then I should be able to access 2 no results pages alternative link rows

      And I fill in the following:
        | Alternative Link Title 0 | News                    |
        | Alternative Link URL 0   | http://news.agency.gov  |
        | Alternative Link Title 1 | Blog                    |
        | Alternative Link URL 1   | http://blog.agency.gov  |

      And I submit the form by pressing "Save"
      Then I should see "You have updated your No Results Page."

      And the "Alternative Link Title 0" field should contain "News"
      And the "Alternative Link URL 0" field should contain "http://news.agency.gov"
      And the "Alternative Link Title 1" field should contain "Blog"
      And the "Alternative Link URL 1" field should contain "http://blog.agency.gov"

    When I am on agency.gov's search page
    Then I should not see "News"
    Then I should not see a link to "http://news.agency.gov"
    Then I should not see "Blog"
    Then I should not see a link to "http://blog.agency.gov"

    And I fill in "Enter your search term" with "hdakfjd;kljowaurei;ak"
    And I submit the form by pressing "Search"

    Then I should see "The GSA apologizes for not having any relevant results."
    And I should see a link to "News" with url for "http://news.agency.gov"
    And I should see a link to "Blog" with url for "http://blog.agency.gov"

    When I go to the agency.gov's No Results Page page
    And I fill in the following:
      | Alternative Link Title 0 |                         |
      | Alternative Link URL 0   |                         |
      | Alternative Link Title 1 | Blog                    |
      | Alternative Link URL 1   | http://blog.agency.gov  |
    And I submit the form by pressing "Save"
    Then I should be able to access 1 no results pages alternative link rows

    When I am on agency.gov's search page
    And I fill in "Enter your search term" with "hdakfjd;kljowaurei;ak"
    And I submit the form by pressing "Search"
    Then I should not see "News"
    Then I should not see a link to "http://news.agency.gov"

  @javascript
  Scenario: Errors when Editing No Results Page
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | website                |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | http://main.agency.gov |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's No Results Page page

    When I fill in the following:
      | Alternative Link Title 0  | News                   |
      | Alternative Link URL 0    | http://news.agency.gov |

    And I submit the form by pressing "Save"
    Then I should not see "You have updated your No Results Page."
    Then I should see "Additional guidance text is required when links are present."

    When I fill in "Additional Guidance Text" with "The GSA apologizes for not having any relevant results."
    And I fill in the following:
      | Alternative Link Title 0  |                        |
      | Alternative Link URL 0    | http://news.agency.gov |

    And I submit the form by pressing "Save"
    Then I should not see "You have updated your No Results Page."
    Then I should see "Alternative link title can't be blank"

    When I fill in the following:
      | Alternative Link Title 0  | News            |
      | Alternative Link URL 0    | news.agency.gov |
    And I submit the form by pressing "Save"
    Then I should see "You have updated your No Results Page."
    And the "Alternative Link URL 0" field should contain "http://news.agency.gov"

  @javascript
  Scenario: Add/edit/remove search page alert
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name   | last_name |
      | agency site  | agency.gov | john@agency.gov | John         | Bar       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Display page
    And I follow "Search Page Alert"
    Then I should see "Update Alert"

    When I fill in the following:
      | Text               | New text alert for the search page. |
    And I select "Active" from "Status"
    And I submit the form by pressing "Save"
    Then I should see "Title can't be blank"

    When I fill in the following:
      | Title               | Alert Title |
    And I submit the form by pressing "Save"
    Then the "Title" field should contain "Alert Title"
    And the "Text" field should contain "New text alert for the search page."
    And the "Status" field should contain "Active"
    And I should see "The alert for this site has been updated."

    When I fill in the following:
      | Title               | New Alert Title |
    And I fill in "Text" with ""
    And I select "Inactive" from "Status"
    And I submit the form by pressing "Save"
    Then I should see "Text can't be blank"

    When I fill in the following:
      | Text              | Updated text for search page alert. |
    And I submit the form by pressing "Save"
    Then the "Title" field should contain "New Alert Title"
    And the "Text" field should contain "Updated text for search page alert."
    And the "Status" field should contain "Inactive"
    And I should see "The alert for this site has been updated."

  Scenario: Editing the Visual Design Settings when "Show Redesign Display Settings" is false
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Visual Design page
    Then I should see "Visual design (new)"
    Then I should see a link to "Preview Redesigned Display" with url that ends with "/search?affiliate=agency.gov&redesign=true"
    And the page body should not contain "These settings are for preview purposes only."

  @javascript
  Scenario: Editing the Visual Design Settings when "Show Redesign Display Settings" is true
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | show_redesign_display_settings |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | true                           |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Visual Design page
    Then I should see "Visual design (new)"
    And the page body should contain "These settings are for preview purposes only."

    When I follow "Fonts & Colors" within the navigation tabs
    Then I should see "Header Links Font Family"
    And the "Header Links Font Family" field should contain "public-sans"
    And I should see "Footer and Results Font Family"
    And the "Footer and Results Font Family" field should contain "public-sans"

    When I select "Georgia" from "Header Links Font Family"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your visual design settings."
    And the "Header Links Font Family" field should contain "georgia"

    When I select "Roboto mono" from "Footer and Results Font Family"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your visual design settings."
    And the "Header Links Font Family" field should contain "georgia"
    And the "Footer and Results Font Family" field should contain "roboto-mono"

    When I follow "Fonts & Colors" within the navigation tabs
    Then I should see "Banner background color"
    And the "Banner background color" field should contain "#F0F0F0"

    When I fill in "Banner background color" with "not a hex code"
    And I fill in "Navigation text color" with ""
    And I submit the form by pressing "Save"
    Then I should see "2 errors prohibited this affiliate from being saved"
    Then I should see "There were problems with the following fields:"
    Then I should see "Banner background color value is not a valid hex code"
    Then I should see "Navigation text color value is not a valid hex code"

    When I fill in "Banner background color" with "#F0F0F0"
    And I fill in "Navigation text color" with "#F0F0F0"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your visual design settings"
    And the "Banner background color" field should contain "#F0F0F0"
    And the "Navigation text color" field should contain "#F0F0F0"

    When I follow "Image Assets" within the navigation tabs
    Then I should see "Favicon URL"
    And I should see "Header logo"
    And I should see "Identifier logo"
    And I should not see "Mark header logo for deletion"
    And I should not see "Header logo alt text"
    And I should not see "Mark identifier logo for deletion"
    And I should not see "Identifier logo alt text"

    When I fill in "Favicon URL" with "https://d3qcdigd1fhos0.cloudfront.net/blog/img/favicon.ico"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your visual design settings"
    And the "Favicon URL" field should contain "https://d3qcdigd1fhos0.cloudfront.net/blog/img/favicon.ico"

    When I attach the file "features/support/logo_mobile_en.png" to "Header logo"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your visual design settings"
    And I should see an image with alt text "Logo"
    And I should see "Header logo alt text"

    When I fill in "Header logo alt text" with "Sample alt text"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your visual design settings"
    And I should see an image with alt text "Sample alt text"

    When I attach the file "features/support/bg.png" to "Header logo"
    And I submit the form by pressing "Save"
    Then I should see "1 error prohibited this affiliate from being saved"
    Then I should see "There were problems with the following fields:"
    Then I should see "Header logo must be under 64 KB"
    And I should see an image with src that contains "logo_mobile_en.png"
    And I should see an image with alt text "Sample alt text"

    When I attach the file "features/support/gsa-logo.svg" to "Identifier logo"
    And I submit the form by pressing "Save"
    Then I should see "1 error prohibited this affiliate from being saved"
    Then I should see "There were problems with the following fields:"
    Then I should see "Identifier logo must be GIF, JPG, or PNG"
    And I should see "Identifier logo"
    And I should not see "Mark identifier logo for deletion"
    And I should not see "Identifier logo alt text"
    And I should see an image with src that contains "logo_mobile_en.png"
    And I should see an image with alt text "Sample alt text"

    When I check "Mark header logo for deletion"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your visual design settings"
    And I should see "Header logo"
    And I should not see an image with src that contains "logo_mobile_en.png"
    And I should see "Identifier logo"
    And I should not see "Mark header logo for deletion"
    And I should not see "Header logo alt text"
    And I should not see "Mark identifier logo for deletion"
    And I should not see "Identifier logo alt text"

  Scenario: Editing the Visual Design Settings when "Show Redesign Display Settings" and "Use Redesigned Results Page" are true
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | show_redesign_display_settings | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | true                           | true                        |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Visual Design page
    Then I should see "Visual design (new)"
    And the page body should not contain "These settings are for preview purposes only."
