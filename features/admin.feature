Feature:  Administration
  Scenario: Visiting the admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    Then I should see "Affiliate Program" in the main navigation bar
    And I should see "APIs & Web Services" in the main navigation bar
    And I should see "Search.USA.gov" in the main navigation bar
    And I should not see a link to "Twitter"
    And I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center
    And I should see "Search.USA.gov Admin Center"
    And I should see "Users" within ".main"
    And I should see "Affiliates"
    And I should see "Affiliate Broadcast"
    And I should see "Calais Related Searches"
    And I should see "SAYT Filters"
    And I should see "SAYT Suggestions Bulk Upload"
    And I should see "Search.USA.gov Boosted Content"
    And I should see "Affiliate Boosted"
    And I should see "Spotlights"
    And I should see "FAQs"
    And I should see "Top Searches"
    And I should see "Top Forms"
    And I should see "Superfresh Urls"
    And I should see "Superfresh Bulk Upload"
    And I should not see "Query Grouping"
    And I should see "Agencies"
    And I should see "affiliate_admin@fixtures.org"
    And I should see "My Account"
    And I should see "Sign Out"

    When I follow "Admin Center" in the main navigation bar
    Then I should be on the admin home page

    When I follow "Sign Out"
    Then I should be on the login page

  Scenario: Clicking on program logo in the admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    When I follow "USASearch Program" in the header
    Then I should be on the program welcome page

  Scenario: Clicking on USASearch breadcrumb link in the admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "USASearch" in the breadcrumbs
    Then I should be on the program welcome page

  Scenario: Clicking on Affiliate Admin breadcrumb link in the admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "Search.USA.gov" in the breadcrumbs
    Then I should be on the searchusagov page

  Scenario: Visiting the admin home page as Marilyn
    Given I am logged in with email "marilyn@fixtures.org" and password "admin"
    When I go to the admin home page
    Then I should see "Users"
    And I should see "Query Grouping"

  Scenario: Visiting the affiliate admin page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | single site      | single.gov       | one@foo.gov           | One Foo             |
    When I go to the admin home page
    And I follow "Affiliates" within ".main"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > Affiliates
    And I should see "Site name"
    And I should see "HTTP parameter site name"
    And I should see "single site"
    And I should see "single.gov"

  Scenario: Visiting the users admin page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "Users" within ".main"
    Then I should be on the users admin page
    And I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > Users

  Scenario: Visiting the Affiliate Broadcast admin page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "Affiliate Broadcast" within ".main"
    Then I should be on the affiliate admin broadcast page
    And I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > Affiliate Broadcast

  Scenario: Visiting the SAYT Filters admin page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "SAYT Filters" within ".main"
    Then I should be on the sayt filters admin page
    And I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > SaytFilters

  Scenario: Sending a welcome email to all affiliates
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
    | display_name     | name             | contact_email         | contact_name        |
    | single site      | single           | one@foo.gov           | One Foo             |
    | multi1 site      | multi1           | two@bar.gov           | Two Bar             |
    | multi2 site      | multi2           | two@bar.gov           | Two Bar             |
    And a clear email queue
    When I go to the affiliate admin broadcast page
    And I fill in "Subject" with "some title"
    And I fill in "Body" with "This is the email body"
    And I press "Send to all affiliates"
    Then I should be on the affiliate admin home page
    And I should see "Message broadcasted to all affiliates successfully"

  Scenario: Uploading, as a logged in admin, a SAYT suggestions text file containing:
            3 new SAYT suggestions, 1 that already exists exactly, 1 that exists in a different case, and a blank line
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following SAYT Suggestions exist:
      | phrase             |
      | tsunami            |
      | hurricane          |
    When I go to the admin home page
    And I follow "SAYT Suggestions Bulk Upload"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > SAYT Suggestions Bulk Upload
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
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > SAYT Suggestions Bulk Upload
    And I should see "Your file could not be processed."

  Scenario: Viewing Boosted Content (both affiliate and Search.USA.gov)
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Boosted Content entries exist:
    | title               | url                     | description                               |
    | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
    | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
    | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And the following Affiliates exist:
    | display_name     | name             | contact_email         | contact_name        |
    | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
    | title               | url                     | description                               |
    | Bar Emergency Page  | http://www.bar.gov/911  | This should not show up in results        |
    When I go to the admin home page
    And I follow "Search.USA.gov Boosted Content"
    And I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > Search.USA.gov Boosted Content
    And I should see "Our Emergency Page"
    And I should not see "Bar Emergency Page"

    When I go to the admin home page
    And I follow "Affiliate Boosted Content"
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > Affiliate Boosted Content
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
    Then I should see the following breadcrumbs: USASearch > Search.USA.gov > Admin Center > Top Searches
    And I should see "Top Searches" within ".main"
    And I should see "Top Search #1:"
    And I should see "Top Search #2:"
    And I should see "Top Search #3:"
    And I should see "Top Search #4:"
    And I should see "Top Search #5:"
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
    And I press "Update Top Searches"
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

  Scenario: Viewing Top Forms
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Top Forms exist:
    | name        | url                     | column_number | sort_order|
    | Form 1      | http://forms.gov/1.pdf  | 1             | 1         |
    | Form 2      | http://forms.gov/2.pdf  | 2             | 1         |
    When I go to the top forms admin page
    Then I should see "You are viewing Column #1"
    And I should see "Form 1" as a Top Form name
    And I should not see "Form 2" as a Top Form name

    When I go to the top forms admin page for column "2"
    Then I should see "You are viewing Column #2"
    And I should see "Form 2" as a Top Form name
    And I should not see "Form 1" as a Top Form name

  Scenario: Adding a new Top Form
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the top forms admin page
    And I fill in "new_name" with "New Form"
    And I fill in "new_url" with "http://forms.gov/new.pdf"
    And I fill in "new_sort_order" with "1"
    And I press "Add Top Form"
    Then I should be on the top forms admin page
    And I should see "Successfully added top form to Column 1 in position 1"
    And I should see "New Form" as a Top Form name

  Scenario: Updating existing Top Forms
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Top Forms exist:
    | name        | url                     | column_number | sort_order|
    | New Forms   |                         | 1             | 1         |
    When I go to the top forms admin page
    And I fill in "top_form_name" with "Newer Forms"
    And I press "Update"
    Then I should be on the top forms admin page
    And I should not see "New Forms" as a Top Form name
    And I should see "Newer Forms" as a Top Form name

  Scenario: Deleting a Top Form
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Top Forms exist:
    | name        | url                     | column_number | sort_order|
    | New Forms   |                         | 1             | 1         |
    | Form 1      | http://forms.gov/1.pdf  | 1             | 2         |
    | Old Forms   |                         | 2             | 1         |
    | Form 2      | http://forms.gov/2.pdf  | 2             | 2         |
    When I go to the top forms admin page
    And I follow "Delete"
    Then I should be on the top forms admin page
    And I should see "Successfully Removed Top Form"
    And I should not see "New Forms" as a Top Form name
    And I should see "Form 1" as a Top Form name

  Scenario: Adding a form in the same position as an existing form
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Top Forms exist:
    | name        | url                     | column_number | sort_order|
    | New Forms   |                         | 1             | 1         |
    | Form 1      | http://forms.gov/1.pdf  | 1             | 2         |
    | Old Forms   |                         | 2             | 1         |
    | Form 2      | http://forms.gov/2.pdf  | 2             | 2         |
    When I go to the top forms admin page
    And I fill in "new_name" with "Form 1"
    And I fill in "new_url" with "http://forms.gov/1.pdf"
    And I fill in "new_sort_order" with "2"
    And I press "Add Top Form"
    Then I should be on the top forms admin page
    And I should see "The Top Form could not be saved."
