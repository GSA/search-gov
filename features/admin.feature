Feature:  Administration
  Scenario: Visiting the admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    Then I should see the browser page titled "Super Admin"
    And I should see the following breadcrumbs: USASearch > Super Admin
    And I should see "Super Admin" in the page header
    And I should see a link to "USASearch" with url for "http://searchblog.usa.gov" in the breadcrumbs
    And I should see "Users"
    And I should see "Affiliates"
    And I should see "SAYT Filters"
    And I should see "SAYT Suggestions Bulk Upload"
    And I should see "Affiliate Boosted"
    And I should see "Top Searches"
    And I should see "Superfresh Urls"
    And I should see "Superfresh Bulk Upload"
    And I should not see "Query Grouping"
    And I should see "Agencies"
    And I should see "affiliate_admin@fixtures.org"
    And I should see "My Account"
    And I should see "Sign Out"

    When I follow "Super Admin" in the main navigation bar
    Then I should be on the admin home page

    When I follow "Sign Out"
    Then I should be on the login page

  Scenario: Visiting the affiliate admin page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
      | display_name | name       | contact_email | contact_name |
      | agency site  | agency.gov | one@foo.gov   | One Foo      |
    And the following site domains exist for the affiliate agency.gov:
      | domain               | site_name      |
      | www1.agency-site.gov | Agency Website |
    When I go to the admin home page
    And I follow "Affiliates" within ".main"
    Then I should see the following breadcrumbs: USASearch > Super Admin > Affiliates
    And I should see "Site name"
    And I should see "Site Handle (visible to searchers in the URL)"
    And I should see "agency site"
    And I should see "agency.gov"
    And I should see "www1.agency-site.gov"

    When I follow "www1.agency-site.gov"
    Then I should see "Agency Website"

  Scenario: Visiting the users admin page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "Users" within ".main"
    Then I should be on the users admin page
    And I should see the following breadcrumbs: USASearch > Super Admin > Users

  Scenario: Visiting the SAYT Filters admin page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "SAYT Filters" within ".main"
    Then I should be on the sayt filters admin page
    And I should see the following breadcrumbs: USASearch > Super Admin > SaytFilters

  Scenario: Uploading, as a logged in admin, a SAYT suggestions text file containing:
            3 new SAYT suggestions, 1 that already exists exactly, 1 that exists in a different case, and a blank line
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following SAYT Suggestions exist:
      | phrase             |
      | tsunami            |
      | hurricane          |
    When I go to the admin home page
    And I follow "SAYT Suggestions Bulk Upload"
    Then I should see the following breadcrumbs: USASearch > Super Admin > SAYT Suggestions Bulk Upload
    And I should see "Create a new text file following the same format as the sample below (one entry per line)"

    When I attach the file "features/support/sayt_suggestions.txt" to "txtfile"
    And I press "Upload"
    Then I should see "3 SAYT suggestions uploaded successfully. 2 SAYT suggestions ignored."

  Scenario: Uploading an invalid SAYT suggestions text file as a logged in admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "SAYT Suggestions Bulk Upload"
    And I attach the file "features/support/cant_read_this.doc" to "txtfile"
    And I press "Upload"
    Then I should see the following breadcrumbs: USASearch > Super Admin > SAYT Suggestions Bulk Upload
    And I should see "Your file could not be processed."

  Scenario: Viewing Boosted Content (both affiliate and Search.USA.gov)
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
    | display_name     | name             | contact_email         | contact_name        |
    | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
    | title               | url                     | description                               |
    | Bar Emergency Page  | http://www.bar.gov/911  | This should not show up in results        |
    When I go to the admin home page
    And I follow "Affiliate Boosted Content"
    Then I should see the following breadcrumbs: USASearch > Super Admin > Affiliate Boosted Content
    And I should see "Bar Emergency Page"
    And I should not see "Our Emergency Page"

  Scenario: Viewing Top Searches
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Top Searches exist:
    | position  | query         |
    | 1         | Top Search 1  |
    | 2         | Top Search 2  |
    | 3         | Top Search 3  |
    | 4         | Top Search 4  |
    | 5         |               |
    When I go to the admin home page
    And I follow "Top Searches"
    Then I should see the following breadcrumbs: USASearch > Super Admin > Top Searches
    And I should see "Top Searches" within ".main"
    And I should see "Term #1:"
    And I should see "Term #2:"
    And I should see "Term #3:"
    And I should see "Term #4:"
    And I should see "Term #5:"
    And the "query1" field should contain "Top Search 1"
    And the "query2" field should contain "Top Search 2"
    And the "query3" field should contain "Top Search 3"
    And the "query4" field should contain "Top Search 4"
    And I should see "Top Search 1" within "#home_searchtrend"
    And I should see "Top Search 2" within "#home_searchtrend"
    And I should see "Top Search 3" within "#home_searchtrend"
    And I should see "Top Search 4" within "#home_searchtrend"

  Scenario: Updating Top Searches
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Top Searches exist:
    | position  | query         | url                 |
    | 1         | Top Search 1  |                     |
    | 2         | Top Search 2  | http://some.com/url |
    | 3         | Top Search 3  |                     |
    | 4         | Top Search 4  |                     |
    | 5         | Top Search 5  |                     |
    When I go to the top search admin page
    And I fill in "query1" with "New Search 1"
    And I fill in "query3" with ""
    And I fill in "query5" with "New Search 5"
    And I fill in "url2" with ""
    And I fill in "url4" with "http://someother.com/url"
    And I press "Update Widget"
    Then I should be on the top search admin page
    And I should see "Top Searches were updated successfully."
    And the "query1" field should contain "New Search 1"
    And the "query3" field should not contain "Top Search 3"
    And the "query5" field should contain "New Search 5"
    And the "url2" field should not contain "http://some.com/url"
    And the "url4" field should contain "http://someother.com/url"
    And I should see "New Search 1" within "#home_searchtrend"
    And I should see "Top Search 2" within "#home_searchtrend"
    And I should not see "Top Search 3" within "#home_searchtrend"
    And I should see "Top Search 4" within "#home_searchtrend"
    And I should see "New Search 5" within "#home_searchtrend"

  Scenario: Viewing affiliate edit page from the Admin Center
    Given the following Affiliates exist:
      | display_name | name       | contact_email                | contact_name | managed_header_home_url | staged_managed_header_home_url | managed_header_text  | staged_managed_header_text  | header_footer_css     | staged_header_footer_css | header          | staged_header          | footer          | staged_footer          |
      | agency site  | agency.gov | affiliate_manager@agency.gov | John Bar     | web.agency.gov          | staged.agency.gov              | this is my SERP page | this is my staged SERP page | #live { color: blue } | #staged { color: green } | <h1>header</h1> | <h1>staged header</h1> | <h1>footer</h1> | <h1>staged footer</h1> |
    And I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the agency.gov's admin edit affiliate page
    Then the "Uses one serp" checkbox should be checked
    And the "Uses managed header footer" checkbox should be checked
    And the "Managed header home url" field should contain "http://web.agency.gov"
    And the "Staged managed header home url" field should contain "http://staged.agency.gov"
    And the "Managed header text" field should contain "this is my SERP page"
    And the textarea labeled "Header footer css" should contain "#live { color: blue }"
    And the textarea labeled "Staged header footer css" should contain "#staged { color: green }"
    And the textarea labeled "Header" should contain "<h1>header</h1>"
    And the textarea labeled "Staged header" should contain "<h1>staged header</h1>"
    And the textarea labeled "Footer" should contain "<h1>footer</h1>"
    And the textarea labeled "Staged footer" should contain "<h1>staged footer</h1>"

  Scenario: Updating affiliate uses_one_serp flag and theme from Admin Center
    Given the following Affiliates exist:
      | display_name | name       | contact_email                | contact_name | uses_one_serp |
      | agency site  | agency.gov | affiliate_manager@agency.gov | John Bar     | false         |
    When I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And I go to the agency.gov's admin edit affiliate page
    And I check "Uses one serp"
    And I select "Gettysburg" from "Theme"
    And I press "Update"
    And I go to the agency.gov's admin edit affiliate page
    Then the "Uses one serp" checkbox should be checked
    And the "Theme" field should contain "elegant"
    And the "Staged theme" field should contain "default"
