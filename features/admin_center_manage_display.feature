Feature: Manage Display
  Scenario: Editing Sidebar Settings on a new site
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And I am logged in with email "john@agency.gov"

    When I go to the agency.gov's Manage Display page

  @javascript

  @javascript
  Scenario: Editing Related Sites
    Given the following BingV7 Affiliates exist:
      | display_name  | name         | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site 1 | 1.agency.gov | john@agency.gov | John       | Bar       | false                       |
      | agency site 2 | 2.agency.gov | john@agency.gov | John       | Bar       | false                       |
      | agency site 3 | 3.agency.gov | john@agency.gov | John       | Bar       | false                       |
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
  Scenario: Editing Image Assets
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name |  website                | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       |  http://main.agency.gov | false                       |
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
  Scenario: Errors when Editing No Results Page
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | website                | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | http://main.agency.gov | false                       |
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

  Scenario: Editing the Visual Design Settings when "Use Redesigned Results Page" is false
    Given the following SearchGov Affiliates exist:
      | display_name    | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | searchgov site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Visual Design page
    Then I should see "Visual design (new)"
    And the page body should contain "These settings are for preview purposes only."

  Scenario: Display sub navigation links when "Use Redesigned Results Page" is true
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | true                        |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Visual Design page
    Then I should see "Visual design (new)"
    And I should not see a link to "Legacy Font & Colors" in the active site sub navigation
    And I should not see a link to "Legacy Image Assets" in the active site sub navigation
    And I should not see a link to "Legacy Header & Footer" in the active site sub navigation

  Scenario: Display sub navigation links when "Use Redesigned Results Page" is false
    Given the following BingV7 Affiliates exist:
      | display_name | name       | contact_email   | first_name | last_name | use_redesigned_results_page |
      | agency site  | agency.gov | john@agency.gov | John       | Bar       | false                       |
    And I am logged in with email "john@agency.gov"
    When I go to the agency.gov's Manage Display page
    Then I should see "Visual design (new)"
    And the page body should not contain "These settings are for preview purposes only."
    And I follow "Legacy Font & Colors"
    And I should see a link to "Legacy Font & Colors" in the active site sub navigation
    And I follow "Legacy Image Assets"
    And I should see a link to "Legacy Image Assets" in the active site sub navigation
    And I follow "Legacy Header & Footer"
    And I should see a link to "Legacy Header & Footer" in the active site sub navigation