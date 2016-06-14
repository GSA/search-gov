Feature: Manage Display

  @javascript
  Scenario: Editing Sidebar Settings on a legacy site
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email   | contact_name | left_nav_label  |
      | agency site  | agency.gov | john@agency.gov | John Bar     | This label is w |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes         |
      | Blog | agency.gov/blog/ |
    And affiliate "agency.gov" has the following RSS feeds:
      | name  | url                          |
      | Press | usasearch.howto.gov/all.atom |
    And the following flickr URLs exist for the site "agency.gov":
      | url                                      |
      | http://www.flickr.com/photos/whitehouse/ |
    And the following Twitter handles exist for the site "agency.gov":
      | screen_name |
      | usasearch   |
    And the following YouTube channels exist for the site "agency.gov":
      | channel_id              | title        |
      | usgovernment_channel_id | USGovernment |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Display page

    Then the "Label for Facets" field should contain "This label is w"
    And the "Default search label" field should contain "Everything"
    And the "Image Search Label 0" field should contain "Images"
    And the "Is Image Search Label 0 navigable" should be switched off
    And the "Document Collection 1" field should contain "Blog"
    And the "Is Document Collection 1 navigable" should be switched on
    And the "Rss Feed 2" field should contain "Press"
    And the "Is Rss Feed 2 navigable" should be switched off
    And the "Rss Feed 3" field should contain "Videos"
    And the "Is Rss Feed 3 navigable" should be switched on

    When I fill in the following:
      | Label for Facets      |               |
      | Default search label  | Web           |
      | Image Search Label 0  | Latest Images |
      | Document Collection 1 | Latest Blog   |
      | Rss Feed 2            | Latest Press  |
      | Rss Feed 3            | Latest Videos |
    And I switch on "Is Image Search Label 0 navigable"
    And I switch off "Is Document Collection 1 navigable"
    And I switch on "Is Rss Feed 2 navigable"
    And I switch off "Is Rss Feed 3 navigable"

    When I submit the form by pressing "Save"
    Then I should see "You have updated your site display settings"
    And the "Label for Facets" field should be blank
    And the "Default search label" field should contain "Web"
    And the "Image Search Label 0" field should contain "Latest Images"
    And the "Is Image Search Label 0 navigable" should be switched on
    And the "Document Collection 1" field should contain "Latest Blog"
    And the "Is Document Collection 1 navigable" should be switched off
    And the "Rss Feed 2" field should contain "Latest Press"
    And the "Is Rss Feed 2 navigable" should be switched on
    And the "Rss Feed 3" field should contain "Latest Videos"
    And the "Is Rss Feed 3 navigable" should be switched off

    When I fill in the following:
      | Label for Facets      | 123456789_123456789_12345 |
      | Default search label  | 123456789_123456789_12345 |
      | Image Search Label 0  | 123456789_123456789_12345 |

    When I submit the form by pressing "Save"
    Then I should see "You have updated your site display settings"
    And the "Label for Facets" field should contain "123456789_123456789_"
    And the "Default search label" field should contain "123456789_123456789_"
    And the "Image Search Label 0" field should contain "123456789_123456789_"

  Scenario: Editing Sidebar Settings on a new site
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
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
      | url                                      |
      | http://www.flickr.com/photos/whitehouse/ |
    And I go to the agency.gov's Manage Display page
    Then I should see "Image Search Label 0"
    And I should see "Rss Feed 1"

    When the following Affiliates exist:
      | display_name | name             | contact_email   | contact_name | is_bing_image_search_enabled |
      | agency site  | bingimageenabled | john@agency.gov | John Bar     | true                         |
    And affiliate "bingimageenabled" has the following RSS feeds:
      | name  | url                 | show_only_media_content | position | oasis_mrss_name |
      | Media | photos.gov/all.atom | true                    | 200      | 100             |
    And I go to the bingimageenabled's Manage Display page
    Then I should see "Image Search Label 0"
    And I should see "Domains/MRSS"
    And I should not see "Rss Feed 1"

    When the following Affiliates exist:
      | display_name | name                | contact_email   | contact_name | is_bing_image_search_enabled |
      | agency site  | bing-image-disabled | john@agency.gov | John Bar     | false                        |
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
      | display_name | name       | contact_email   | contact_name | agency_abbreviation | gets_i14y_results |
      | agency site  | agency.gov | john@agency.gov | John Bar     | DOC                 | true              |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes         |
      | Blog | agency.gov/blog/ |
    And affiliate "agency.gov" has the following RSS feeds:
      | name  | url                          | show_only_media_content |
      | Press | usasearch.howto.gov/all.atom | false                   |
      | DMA   | media.dma.mil/mrss/portal/144/detailpage/www.af.mil/News/Photos.aspx | true                   |
    And the following Instagram usernames exist for the site "agency.gov":
      | username   |
      | whitehouse |
      | dg_search  |
    And the following flickr URLs exist for the site "agency.gov":
      | url                                      |
      | http://www.flickr.com/photos/whitehouse/ |
    And the following Twitter handles exist for the site "agency.gov":
      | screen_name |
      | usasearch   |
    And the following YouTube channels exist for the site "agency.gov":
      | channel_id              | title        |
      | usgovernment_channel_id | USGovernment |
    And I am logged in with email "john@agency.gov" and password "random_string"
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
    And I should see "Recent Tweets"

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
      | display_name  | name         | contact_email   | contact_name |
      | agency site 1 | 1.agency.gov | john@agency.gov | John Bar     |
      | agency site 2 | 2.agency.gov | john@agency.gov | John Bar     |
      | agency site 3 | 3.agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
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
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
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
  Scenario: Editing Font & Colors on legacy Affiliate
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Font & Colors page
    Then the "Font Family" field should contain "Default"
    And the "Default" radio button should be checked
    And the "Show Desktop Content Border" checkbox should not be checked
    And the "Show Desktop Content Box Shadow" checkbox should not be checked

    When I select "Helvetica, sans-serif" from "Font Family"
    And I choose "Custom"
    And I fill in the following:
      | Page Background Color              | #000001 |
      | Button Background Color            | #000020 |
      | Mobile Header Background Color     | #000300 |
      | Mobile Footer Background Color     | #004000 |
      | Mobile Navigation Background Color | #050000 |
      | Active Navigation Color            | #600000 |
      | Mobile Navigation Link Color       | #000007 |
      | Desktop Content Background Color   | #000080 |
      | Desktop Content Border Color       | #000900 |
      | Desktop Content Box Shadow Color   | #00A000 |
      | Desktop Icon Color                 | #0B0000 |
      | Link Color                         | #A00000 |
      | Visited Link Color                 | #0B0000 |
      | Result URL Color                   | #00C000 |
      | Description Text Color             | #000D00 |
    And I check "Show Desktop Content Border"
    And I check "Show Desktop Content Box Shadow"
    And I submit the form by pressing "Save"

    Then I should see "You have updated your font & colors"
    And the "Font Family" field should contain "Helvetica, sans-serif"
    And the "Custom" radio button should be checked
    And the "Page Background Color" field should contain "#000001"
    And the "Button Background Color" field should contain "#000020"
    And the "Mobile Header Background Color" field should contain "#000300"
    And the "Mobile Footer Background Color" field should contain "#004000"
    And the "Mobile Navigation Background Color" field should contain "#050000"
    And the "Active Navigation Color" field should contain "#600000"
    And the "Mobile Navigation Link Color" field should contain "#000007"
    And the "Desktop Content Background Color" field should contain "#000080"
    And the "Desktop Content Border Color" field should contain "#000900"
    And the "Desktop Content Box Shadow Color" field should contain "#00A000"
    And the "Desktop Icon Color" field should contain "#0B0000"
    And the "Link Color" field should contain "#A00000"
    And the "Visited Link Color" field should contain "#0B0000"
    And the "Result URL Color" field should contain "#00C000"
    And the "Description Text Color" field should contain "#000D00"

  @javascript
  Scenario: Editing Image Assets on legacy Affiliate
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email   | contact_name | uses_managed_header_footer | website                |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true                       | http://main.agency.gov |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Image Assets page
    Then the "Logo Alignment" field should contain "center"

    When I fill in "Favicon URL" with "https://9fddeb862c037f6d2190-f1564c64756a8cfee25b6b19953b1d23.ssl.cf2.rackcdn.com/favicon.ico"
    And I attach the file "features/support/small.jpg" to "Legacy Logo"
    And I attach the file "features/support/logo_mobile_en.png" to "Logo"
    When I fill in "Logo Alt Text" with "  Awesome   Agency  "
    And I select "left" from "Logo Alignment"
    And I attach the file "features/support/bg.png" to "Page Background Image"
    And I select "repeat-y" from "Page Background Image Repeat"
    And I submit the form by pressing "Save"

    Then I should see "You have updated your image assets"
    And the "Favicon URL" field should contain "https://9fddeb862c037f6d2190-f1564c64756a8cfee25b6b19953b1d23.ssl.cf2.rackcdn.com/favicon.ico"
    And I should see an image with alt text "Legacy Logo"
    And I should see an image with alt text "Logo"
    And the "Logo Alignment" field should contain "left"
    And the "Logo Alt Text" field should contain "Awesome Agency"
    And I should see an image with alt text "Page Background Image"
    And the "Page Background Image Repeat" field should contain "repeat-y"

    When I am on agency.gov's search page
    Then I should see an image link to "logo" with url for "http://main.agency.gov"
    And the page body should contain "bg.png"
    When I am on agency.gov's mobile search page
    Then I should see an image link to "Awesome Agency" with url for "http://main.agency.gov"
    And the page body should contain "logo_mobile_en.png"
    And I should see a left aligned SERP logo

    When I go to the agency.gov's Image Assets page
    And I check "Mark Legacy Logo for Deletion"
    And I check "Mark Logo for Deletion"
    And I check "Mark Page Background Image for Deletion"
    And I submit the form by pressing "Save"
    Then I should see "You have updated your image assets"
    And I should not see an image with alt text "Legacy Logo"
    And I should not see an image with alt text "Logo"
    And I should not see an image with alt text "Page Background Image"

    When I attach the file "features/support/very_large.jpg" to "Legacy Logo"
    When I attach the file "features/support/very_large.jpg" to "Logo"
    When I attach the file "features/support/very_large.jpg" to "Page Background Image"
    And I submit the form by pressing "Save"
    Then I should see "Legacy Logo file size must be under 512 KB"
    Then I should see "Logo file size must be under 64 KB"
    Then I should see "Page Background Image file size must be under 512 KB"
    And I should not see an image with alt text "Legacy Logo"
    And I should not see an image with alt text "Logo"
    And I should not see an image with alt text "Page Background Image"

  @javascript
  Scenario: Editing Image Assets on non legacy Affiliate
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | uses_managed_header_footer | website                |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true                       | http://main.agency.gov |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Image Assets page
    And I fill in "Favicon URL" with "https://9fddeb862c037f6d2190-f1564c64756a8cfee25b6b19953b1d23.ssl.cf2.rackcdn.com/favicon.ico"
    And I attach the file "features/support/logo_mobile_en.png" to "Logo"
    And I select "left" from "Logo Alignment"
    When I fill in "Logo Alt Text" with "  Awesome   Agency  "
    And I submit the form by pressing "Save"
    Then I should see "You have updated your image assets"
    And the "Favicon URL" field should contain "https://9fddeb862c037f6d2190-f1564c64756a8cfee25b6b19953b1d23.ssl.cf2.rackcdn.com/favicon.ico"
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
  Scenario: Editing Managed Header & Footer
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email   | contact_name | footer_fragment                   |
      | agency site  | agency.gov | john@agency.gov | John Bar     | <strong>my HTML fragment</strong> |
    And affiliate "agency.gov" has the following document collections:
      | name                 | prefixes             | position | is_navigable |
      | Active site search   | http://apps.usa.gov/ | 3        | true         |
      | Inactive site search | http://apps.usa.gov/ | 6        | false        |
    And affiliate "agency.gov" has the following RSS feeds:
      | name                 | url                            | is_navigable | position | show_only_media_content |
      | Inactive news search | http://en.agency.gov/feed/News | false        | 5        | false                   |
    And I am logged in with email "john@agency.gov" and password "random_string"

    When I am on agency.gov's mobile search page
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
    Then I should see a link to "News" with url for "http://news.agency.gov"
    And I should see a link to "Blog" with url for "http://blog.agency.gov"
    And I should see a link to "Contact" with url for "mailto:contact@agency.gov"
    And I should see a link to "Terms of Service" with url for "http://tos.agency.gov"

    When I am on agency.gov's mobile search page
    And the page body should contain "mini_logo.png"
    Then I should see "Office website of the Awesome Agency"
    And I should see a left aligned menu button
    And I should see "my HTML fragment" within the mobile footer
    And I should not see "strong" within the mobile footer

    When I press "Browse site"
    Then I should find "News" in the main menu
    Then I should see a link to "News" with url for "http://news.agency.gov"
    Then I should see a link to "Blog" with url for "http://blog.agency.gov"
    Then I should see a link to "Contact" with url for "mailto:contact@agency.gov"
    Then I should see a link to "Terms of Service" with url for "http://tos.agency.gov"

    When I am on agency.gov's "Inactive site search" mobile site search page
    And I press "Browse site"
    Then I should find "News" in the main menu
    Then I should see a link to "News" with url for "http://news.agency.gov"
    Then I should see a link to "Blog" with url for "http://blog.agency.gov"

    When I am on agency.gov's "Inactive news search" mobile news search page
    And I press "Browse site"
    Then I should find "News" in the main menu
    Then I should see a link to "News" with url for "http://news.agency.gov"
    Then I should see a link to "Blog" with url for "http://blog.agency.gov"

    When I go to the agency.gov's Header & Footer page
    And I follow "Switch to Advanced Mode"
    Then I should see "CSS to customize the top and bottom of your search results page"

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
  Scenario: Error when Editing Managed Header & Footer
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    And no emails have been sent
    When I go to the agency.gov's Header & Footer page
    And I fill in the following:
      | Header Link Title 0 | News               |
      | Footer Link URL 0   | contact.agency.gov |
    And I submit the form by pressing "Save"
    Then I should see "Header link URL can't be blank"
    Then I should see "Footer link title can't be blank"

  @javascript
  Scenario: Editing Custom Header & Footer
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email   | contact_name | staged_header |
      | agency site  | agency.gov | john@agency.gov | John Bar     | header        |
    And I am logged in with email "john@agency.gov" and password "random_string"
    And no emails have been sent
    When I go to the agency.gov's Header & Footer page
    And I follow "Switch to Advanced Mode"
    And I fill in the following:
      | CSS to customize the top and bottom of your search results page | .staged { color: blue } |
      | HTML to customize the top of your search results page           | Staged Header           |
      | HTML to customize the bottom of your search results page        | Staged Footer           |
    And I submit the form by pressing "Save for Preview"
    Then I should see "You have saved header and footer changes for preview"
    And the "CSS to customize the top and bottom of your search results page" field should contain ".staged \{ color: blue \}"
    And the "HTML to customize the top of your search results page" field should contain "Staged Header"
    And the "HTML to customize the bottom of your search results page" field should contain "Staged Footer"

    When I access the dropdown button group within the "Header & Footer form"
    And I press "Make Live"
    Then I should see "You have saved header and footer changes to your live site"

    When "john@agency.gov" opens the email
    Then I should see "Your header and footer for agency site changed" in the email subject
    And I should see "You've changed the header or footer for agency site so we're sending you this email for your records" in the email body
    And I should see "Staged Header" in the email body
    And I should see "Staged Footer" in the email body

    When I fill in the following:
      | CSS to customize the top and bottom of your search results page | .staged { color: red } |
    And I submit the form by pressing "Save for Preview"
    Then I should see "You have saved header and footer changes for preview"

    When I access the dropdown button group within the "Header & Footer form"
    And I press "Cancel Changes"
    Then I should see "You have cancelled header and footer changes"

    When I follow "Switch to Simple Mode"
    Then I should see "Header Links"

  @javascript
  Scenario: Error when Editing Custom Header & Footer
    Given the following legacy Affiliates exist:
      | display_name   | name       | contact_email   | contact_name  |
      | agency site    | agency.gov | john@agency.gov | John Bar      |
    And I am logged in with email "john@agency.gov" and password "random_string"
    And no emails have been sent
    When I go to the agency.gov's Header & Footer page
    And I follow "Switch to Advanced Mode"
    And I fill in the following:
      | CSS to customize the top and bottom of your search results page | .staged { color: |
    And I submit the form by pressing "Save for Preview"
    Then I should see "Invalid CSS"

    When I access the dropdown button group within the "Header & Footer form"
    And I press "Make Live"
    Then I should see "Invalid CSS"

    @javascript
    Scenario: Editing No Results Page on non legacy Affiliate
      Given the following Affiliates exist:
        | display_name | name       | contact_email   | contact_name | uses_managed_header_footer | website                |
        | agency site  | agency.gov | john@agency.gov | John Bar     | true                       | http://main.agency.gov |
      And I am logged in with email "john@agency.gov" and password "random_string"
      And no emails have been sent
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

    When I am on agency.gov's mobile search page
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

    When I am on agency.gov's mobile search page
    And I fill in "Enter your search term" with "hdakfjd;kljowaurei;ak"
    And I submit the form by pressing "Search"
    Then I should not see "News"
    Then I should not see a link to "http://news.agency.gov"

  @javascript
  Scenario: Errors when Editing No Results Page on non legacy Affiliate
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | uses_managed_header_footer | website                |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true                       | http://main.agency.gov |
    And I am logged in with email "john@agency.gov" and password "random_string"
    And no emails have been sent
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
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
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

    
