Feature: Manage Display

  @javascript
  Scenario: Editing Sidebar Settings
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
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
    And the following YouTube usernames exist for the site "agency.gov":
      | username     |
      | usgovernment |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Display page

    Then the "Label for Sidebar" field should be blank
    And the "Default search label" field should contain "Everything"
    And the "Image Search Label 0" field should contain "Images"
    And the "Is Image Search Label 0 navigable" should be switched on
    And the "Document Collection 1" field should contain "Blog"
    And the "Is Document Collection 1 navigable" should be switched on
    And the "Rss Feed 2" field should contain "Press"
    And the "Is Rss Feed 2 navigable" should be switched off
    And the "Rss Feed 3" field should contain "Videos"

    When I fill in the following:
      | Label for Sidebar     | Search        |
      | Default search label  | Web           |
      | Image Search Label 0  | Latest Images |
      | Document Collection 1 | Latest Blog   |
      | Rss Feed 2            | Latest Press  |
      | Rss Feed 3            | Latest Videos |
    And I switch off "Is Image Search Label 0 navigable"
    And I switch off "Is Document Collection 1 navigable"
    And I switch on "Is Rss Feed 2 navigable"
    And I switch on "Is Rss Feed 3 navigable"

    And I press "Save"
    Then I should see "You have updated your site display settings"
    And the "Label for Sidebar" field should contain "Search"
    And the "Default search label" field should contain "Web"
    And the "Image Search Label 0" field should contain "Latest Images"
    And the "Is Image Search Label 0 navigable" should be switched off
    And the "Document Collection 1" field should contain "Latest Blog"
    And the "Is Document Collection 1 navigable" should be switched off
    And the "Rss Feed 2" field should contain "Latest Press"
    And the "Is Rss Feed 2 navigable" should be switched on
    And the "Rss Feed 3" field should contain "Latest Videos"
    And the "Is Rss Feed 3 navigable" should be switched on

  @javascript
  Scenario: Editing GovBoxes Settings
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
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
    And the following YouTube usernames exist for the site "agency.gov":
      | username     |
      | usgovernment |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Manage Display page

    And the "Rss govbox label" field should contain "News"
    And the "Is rss govbox enabled" should be switched off
    And the "Is video govbox enabled" should be switched on
    And the "Is photo govbox enabled" should be switched on
    And the "Jobs enabled" should be switched off
    And the "Is agency govbox enabled" should be switched off
    And the "Is related searches enabled" should be switched on
    And the "Is sayt enabled" should be switched on
    And the "Is medline govbox enabled" should be switched off
    And I should see "Recent Tweets"

    When I fill in "Rss govbox label" with "Latest News"
    And I switch on "Is rss govbox enabled"
    And I switch off "Is video govbox enabled"
    And I switch off "Is photo govbox enabled"
    And I switch on "Jobs enabled"
    And I switch on "Is agency govbox enabled"
    And I switch off "Is related searches enabled"
    And I switch on "Is medline govbox enabled"
    And I switch off "Is sayt enabled"

    And I press "Save"
    Then I should see "You have updated your site display settings"
    And the "Rss govbox label" field should contain "Latest News"
    And the "Is rss govbox enabled" should be switched on
    And the "Is video govbox enabled" should be switched off
    And the "Is photo govbox enabled" should be switched off
    And the "Jobs enabled" should be switched on
    And the "Is agency govbox enabled" should be switched on
    And the "Is related searches enabled" should be switched off
    And the "Is medline govbox enabled" should be switched on
    And the "Is sayt enabled" should be switched off

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
    And I press "Save"
    Then I should see "You have updated your site display settings"
    And the "Connection site handle 0" field should contain "2.agency.gov"
    And the "Connection label 0" field should contain "agency site 2 SERP"
    And the "Connection site handle 1" field should contain "3.agency.gov"
    And the "Connection label 1" field should contain "agency site 3 SERP"

    And I fill in the following:
      | Connection site handle 0 | |
      | Connection label 0       | |
    And I press "Save"
    Then I should see "You have updated your site display settings"
    And the "Connection site handle 0" field should contain "3.agency.gov"
    And the "Connection label 0" field should contain "agency site 3 SERP"

  @javascript
  Scenario: Editing Font & Colors
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Font & Colors page
    Then the "Font Family" field should contain "Arial, sans-serif"
    And the "Default" radio button should be checked
    And the "Show Content Border" checkbox should not be checked
    And the "Show Content Box Shadow" checkbox should not be checked

    When I select "Helvetica, sans-serif" from "Font Family"
    And I choose "Custom"
    And I fill in the following:
      | Page Background Color    | #000001 |
      | Content Background Color | #000020 |
      | Content Border Color     | #000300 |
      | Content Box Shadow Color | #004000 |
      | Icon Color               | #050000 |
      | Button Background Color  | #600000 |
      | Active Sidebar Color     | #000007 |
      | Link Color               | #000080 |
      | Visited Link Color       | #000900 |
      | Result URL Color         | #00A000 |
      | Description Text Color   | #0B0000 |
    And I check "Show Content Border"
    And I check "Show Content Box Shadow"
    And I press "Save"

    Then I should see "You have updated your font & colors"
    And the "Font Family" field should contain "Helvetica, sans-serif"
    And the "Custom" radio button should be checked
    And the "Page Background Color" field should contain "#000001"
    And the "Content Background Color" field should contain "#000020"
    And the "Show Content Border" checkbox should be checked
    And the "Content Border Color" field should contain "#000300"
    And the "Show Content Box Shadow" checkbox should be checked
    And the "Content Box Shadow Color" field should contain "#004000"
    And the "Icon Color" field should contain "#050000"
    And the "Button Background Color" field should contain "#600000"
    And the "Active Sidebar Color" field should contain "#000007"
    And the "Link Color" field should contain "#000080"
    And the "Visited Link Color" field should contain "#000900"
    And the "Result URL Color" field should contain "#00A000"
    And the "Description Text Color" field should contain "#0B0000"

  @javascript
  Scenario: Editing Image Assets
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | uses_managed_header_footer | website                |
      | agency site  | agency.gov | john@agency.gov | John Bar     | true                       | http://main.agency.gov |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Image Assets page
    And I fill in "Favicon URL" with "https://9fddeb862c037f6d2190-f1564c64756a8cfee25b6b19953b1d23.ssl.cf2.rackcdn.com/favicon.ico"
    And I attach the file "features/support/small.jpg" to "Logo"
    And I attach the file "features/support/logo_mobile_en.png" to "Mobile Logo"
    And I attach the file "features/support/bg.png" to "Page Background Image"
    And I select "repeat-y" from "Page Background Image Repeat"
    And I press "Save"
    Then I should see "You have updated your image assets"
    And the "Favicon URL" field should contain "https://9fddeb862c037f6d2190-f1564c64756a8cfee25b6b19953b1d23.ssl.cf2.rackcdn.com/favicon.ico"
    And I should see an image with alt text "Logo"
    And I should see an image with alt text "Mobile Logo"
    And I should see an image with alt text "Page Background Image"
    And the "Page Background Image Repeat" field should contain "repeat-y"

    When I am on agency.gov's search page
    Then I should see an image link to "logo" with url for "http://main.agency.gov"
    And the page body should contain "bg.png"
    When I am on agency.gov's mobile search page
    Then I should see an image link to "agency site" with url for "http://main.agency.gov"

    When I go to the agency.gov's Image Assets page
    And I check "Mark Logo for Deletion"
    And I check "Mark Mobile Logo for Deletion"
    And I check "Mark Page Background Image for Deletion"
    And I press "Save"
    Then I should see "You have updated your image assets"
    And I should not see an image with alt text "Logo"
    And I should not see an image with alt text "Mobile Logo"
    And I should not see an image with alt text "Page Background Image"

    When I attach the file "features/support/very_large.jpg" to "Logo"
    When I attach the file "features/support/very_large.jpg" to "Mobile Logo"
    When I attach the file "features/support/very_large.jpg" to "Page Background Image"
    And I press "Save"
    Then I should see "Logo file size must be under 512 KB"
    Then I should see "Mobile Logo file size must be under 56 KB"
    Then I should see "Page Background Image file size must be under 512 KB"
    And I should not see an image with alt text "Logo"
    And I should not see an image with alt text "Mobile Logo"
    And I should not see an image with alt text "Page Background Image"

  @javascript
  Scenario: Editing Managed Header & Footer
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    When I go to the agency.gov's Header & Footer page
    And I fill in the following:
      | Header Link Title 0 | News               |
      | Header Link URL 0   | news.agency.gov    |
      | Footer Link Title 0 | Contact            |
      | Footer Link URL 0   | contact.agency.gov |
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
    And I press "Save"
    Then I should see "You have updated your header and footer links"
    And the "Header Link Title 0" field should contain "News"
    And the "Header Link URL 0" field should contain "http://news.agency.gov"
    And the "Header Link Title 1" field should contain "Blog"
    And the "Header Link URL 1" field should contain "http://blog.agency.gov"
    And the "Footer Link Title 0" field should contain "Contact"
    And the "Footer Link URL 0" field should contain "http://contact.agency.gov"
    And the "Footer Link Title 1" field should contain "Terms"
    And the "Footer Link URL 1" field should contain "http://tos.agency.gov"

    When I am on agency.gov's search page
    Then I should see a link to "News" with url for "http://news.agency.gov"
    Then I should see a link to "Blog" with url for "http://blog.agency.gov"
    Then I should see a link to "Contact" with url for "http://contact.agency.gov"
    Then I should see a link to "Terms of Service" with url for "http://tos.agency.gov"

    When I go to the agency.gov's Header & Footer page
    And I follow "Switch to Advanced Mode"
    Then I should see "CSS to customize the top and bottom of your search results page"

  @javascript
  Scenario: Error when Editing Managed Header & Footer
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    And no emails have been sent
    When I go to the agency.gov's Header & Footer page
    And I fill in the following:
      | Header Link Title 0 | News               |
      | Footer Link URL 0   | contact.agency.gov |
    And I press "Save"
    Then I should see "Header link URL can't be blank"
    Then I should see "Footer link title can't be blank"

  @javascript
  Scenario: Editing Custom Header & Footer
    Given the following Affiliates exist:
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
    And I press "Save for Preview"
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
    And I press "Save for Preview"
    Then I should see "You have saved header and footer changes for preview"

    When I access the dropdown button group within the "Header & Footer form"
    And I press "Cancel Changes"
    Then I should see "You have cancelled header and footer changes"

    When I follow "Switch to Simple Mode"
    Then I should see "Header Links"

  @javascript
  Scenario: Error when Editing Custom Header & Footer
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name |
      | agency site  | agency.gov | john@agency.gov | John Bar     |
    And I am logged in with email "john@agency.gov" and password "random_string"
    And no emails have been sent
    When I go to the agency.gov's Header & Footer page
    And I follow "Switch to Advanced Mode"
    And I fill in the following:
      | CSS to customize the top and bottom of your search results page | .staged { color: |
    And I press "Save for Preview"
    Then I should see "Invalid CSS"

    When I access the dropdown button group within the "Header & Footer form"
    And I press "Make Live"
    Then I should see "Invalid CSS"
