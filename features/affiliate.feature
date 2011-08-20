Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    When I go to the affiliate welcome page
    Then I should see the following breadcrumbs: USASearch > Affiliate Program
    And I should see "Hosted Search Services"
    Then I should see "Affiliate Program"
    And I should see "APIs & Web Services"
    And I should see "Search.USA.gov"
    And I should not see "USA Search Program"
    And I should not see "Admin Center"
    And I should not see "Analytics Center"
    And I should not see "Affiliate Center"
    And I should not see "Developer"

    When I follow "Register Now"
    Then I should see "Sign In to Use Our Services"

  Scenario: Visiting the affiliate welcome page as affiliate admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the affiliate welcome page
    Then I should see "Admin Center" link in the main navigation bar
    And I should not see "Analytics Center" link in the main navigation bar
    And I should not see "Affiliate Center" link in the main navigation bar
    And I should see the following breadcrumbs: USASearch > Affiliate Program

  Scenario: Visiting the affiliate welcome page as affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the affiliate welcome page
    Then I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Mobile" with url for "http://m.usa.gov" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    And I should see a link to "Share" with url for "http://www.addthis.com/bookmark.php" in the connect section
    And I should see "Affiliate Center" link in the main navigation bar
    And I should not see "Admin Center" link in the main navigation bar
    And I should not see "Analytics Center" link in the main navigation bar
    And I should see the following breadcrumbs: USASearch > Affiliate Program

  Scenario: Visiting the Affiliate API Pages as affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the recalls api page
    Then I should see the API key
    And I should see the TOS link
    And I should see "By using a USASearch API, you agree to our"
    When I follow "Search API"
    Then I should see the API key
    And I should see the TOS link
    And I should see "By using a USASearch API, you agree to our"
    When I follow "Terms of Service"
    Then I should see the API key
    And I should not see the TOS link
    And I should not see "By using a USASearch API, you agree to our"

  Scenario: Visiting the affiliate admin page as affiliate with existing sites
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    Then I should see "Affiliate Center" within "title"
    And I should not see a link to "Twitter"
    And I should see "Affiliate Center" within ".main"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center
    And I should see "Site List"
    And I should see "add new site"

    When I follow "Affiliate Center" in the main navigation bar
    Then I should be on the affiliate admin page

  Scenario: Visiting the affiliate admin page as affiliate without existing sites
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    Then I should see "Affiliate Center" within "title"
    And I should see "Affiliate Center" within ".main"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center
    And I should see "Add New Site"

  Scenario: Visiting the account page as a logged-in user with affiliates
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | has_staged_content |
      | foo site         | multifoo.gov     | two@bar.gov           | Two Bar             | true               |
      | bar site         | multibar.gov     | two@bar.gov           | Two Bar             | false              |
      | other site       | other.gov        | other@other.gov       | Other Bar           | false              |
    And I am logged in with email "two@bar.gov" and password "random_string"
    When I go to the user account page
    Then I should see "foo site"
    And I should see "bar site"
    And I should not see "other site"
    When I follow "Affiliate Center"
    Then I should see "foo site" for site named "foo site"
    Then I should see "View Current" for site named "foo site"
    Then I should see "View Staged" for site named "foo site"
    Then I should see "Push Changes" button for site named "foo site"
    Then I should see "Cancel Changes" button for site named "foo site"
    Then I should see "Delete Site" button for site named "foo site"
    Then I should see "bar site" for site named "bar site"
    Then I should see "View Current" for site named "bar site"
    Then I should not see "View Staged" for site named "bar site"
    Then I should not see "Push Changes" button for site named "bar site"
    Then I should not see "Cancel Changes" button for site named "bar site"
    Then I should see "Delete Site" button for site named "bar site"
    And I should not see "other site"
    And I should not see "multifoo.gov"
    And I should not see "multibar.gov"
    And I should not see "other.gov"

  Scenario: Visiting the affiliate center as an affiliate with multiple sites
    Given the following Affiliates exist:
      | display_name     | name             | contact_email            | contact_name        | has_staged_content |
      | zzz site         | zzz.gov          | sorted@bar.gov           | Two Bar             | true               |
      | aaa site         | aaa.gov          | sorted@bar.gov           | Two Bar             | false              |
      | ccc site         | ccc.gov          | sorted@bar.gov           | Two Bar             | false              |
      | 111 site         | 111.gov          | sorted@bar.gov           | Two Bar             | false              |
      | bar site         | multibar.gov     | sorted@bar.gov           | Two Bar             | false              |
    And I am logged in with email "sorted@bar.gov" and password "random_string"
    When I am on the affiliate admin page
    Then I should see sorted sites in the site dropdown list
    Then I should see sorted sites in the site list

  Scenario: Adding a new affiliate
    Given I am logged in with email "affiliate_with_no_contact_info@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    Then I should see "Add a New Site" within "title"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > Add New Site
    And I should see "Add a New Site" within ".main"
    And I should see "Step 1. Enter contact information" in the site wizards header
    And I should see "Contact information"
    And the "Name*" field should contain "A New Affiliate"
    And the "Email*" field should contain "affiliate_with_no_contact_info@fixtures.org"
    And I fill in the following:
      | Government organization                    | Awesome Agency             |
      | Phone                                      | 202-123-4567               |
      | Organization address                       | 123 Penn Avenue            |
      | Address 2                                  | Ste 456                    |
      | City                                       | Reston                     |
      | Zip                                        | 20022                      |
    And I select "Virginia" from "State"
    And I press "Next"
    Then I should see "Add a New Site" within "title"
    And I should see "Step 2. Set up site" in the site wizards header
    And I should see "Site information"
    And I fill in the following:
      | Site name                 | My awesome agency                |
      | Domains to search         | www.awesomeagency.gov            |
    And I press "Next"
    Then I should see "Add a New Site" within "title"
    And I should see "Site successfully created"
    And I should see "Step 3. Get the code" in the site wizards header
    And I should see "View search results page"
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should see "White House - My awesome agency Search Results"

  Scenario: Affiliate user who filled out contact information should not have to fill out the form again
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > Add New Site
    And I should see "Add a New Site"
    And I should see "Step 1. Enter contact information" in the site wizards header
    And I should see "Contact information"
    And the "Name*" field should contain "A New Manager"
    And the "Email*" field should contain "affiliate_manager_with_no_affiliates@fixtures.org"
    And the "Government organization*" field should contain "Agency"
    And the "Phone*" field should contain "301-123-4567"
    And the "Organization address*" field should contain "123 Penn Ave"
    And the "Address 2" field should contain "Ste 100"
    And the "City*" field should contain "Reston"
    And the "State*" field should contain "VA"
    And the "Zip*" field should contain "20022"
    And I press "Next"
    Then I should see "Step 2. Set up site" in the site wizards header

  Scenario: Affiliates receive confirmation email when creating a new affiliate
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    Then "affiliate_manager_with_no_affiliates@fixtures.org" should receive an email
    When I open the email
    Then I should see "Your new Affiliate site" in the email subject
    And I should see "Dear A New Manager" in the email body
    And I should see "Site name: My awesome agency" in the email body
    And I should see "affiliate_manager_with_no_affiliates@fixtures.org" in the email body

  Scenario: Clicking on Adding additional sites in Step 3. Get the code
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    And I follow "Adding additional sites"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > Add New Site

  Scenario: Clicking on Customizing the look and feel in Step 3. Get the code
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    And I follow "Customizing the look and feel"
    Then I should see "Look and Feel of the Search Results Page" within "title"

  Scenario: Clicking on Setting up the type-ahead search in Step 3. Get the code
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    And I follow "Setting up the type-ahead search"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > My awesome agency > Type-ahead Search

  Scenario: Clicking on Go to Affiliate Center in Step 3. Get the code
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    And I follow "Go to Affiliate Center"
    Then I should be on the affiliate admin page

   Scenario: Adding an affiliate without filling out contact information should fail
    Given I am logged in with email "affiliate_with_no_contact_info@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    Then I should see "Organization name can't be blank"
    Then I should see "Phone can't be blank"
    Then I should see "Address can't be blank"
    Then I should see "City can't be blank"
    Then I should see "Zip can't be blank"

  Scenario: Adding an affiliate without site display name should fail
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    And I press "Next"
    Then I should see "Site name can't be blank"
    And I should not see "HTTP parameter site name can't be blank"
    And I should not see "HTTP parameter site name is too short"
    And I should not see "HTTP parameter site name is invalid"

  Scenario: Adding a new site as an affiliate user with pending_contact_information status
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@corporate.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I choose "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the affiliate admin page
    And I should see "Affiliate Center" link in the main navigation bar
    And I should see "Contact information"
    When I follow "Add New Site"
    Then I should be on the affiliate admin page
    And I should see "Your contact information is not complete."

  Scenario: Adding a new site as an affiliate user with pending_approval status
    Given I am logged in with email "affiliate_manager_with_pending_approval_status@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    Then I should be on the affiliate admin page
    And I should see "Your account has not been approved. Please try again when you are set up."

  Scenario: Adding a new site as an affiliate user with pending_email_verification status
    Given I am logged in with email "affiliate_manager_with_pending_email_verification_status@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    Then I should be on the affiliate admin page
    And I should see "Your email address has not been verified. Please check your inbox so we may verify your email address."

  Scenario: Deleting an affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I press "Delete Site"
    Then I should be on the affiliate admin page
    And I should see "Site deleted"

  Scenario: Visiting the site information page
    Given the following Affiliates exist:
      | display_name     | name        | domains       | staged_domains       | contact_email         | contact_name        |
      | aff site         | aff.gov     | example.org   | example.org          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Site information"
    Then I should see "Site Information" within "title"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Site Information
    And I should see "Site Information" within ".main"
    And the "Site name" field should contain "aff site"
    And the "HTTP parameter site name" field should contain "aff.gov"
    And the "Domains to search" field should contain "example.org"
    And I should see "Cancel"
    When I follow "Cancel"
    Then I should be on the "aff site" affiliate page

  Scenario: Editing site information and saving it for preview
    Given the following Affiliates exist:
      | display_name     | name            | domains       | contact_email         | contact_name        |
      | aff site         | aff.gov         | example.org   | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Site information"
    And I fill in the following:
      | Site name                  | new aff site        |
      | Site URL                   | www.aff.gov         |
      | Domains to search          | data.gov            |
    And I press "Save for Preview"
    Then I should be on the "new aff site" affiliate page
    And I should see "Staged changes to your site successfully"
    And I should see "Site: new aff site"
    And I should see "www.aff.gov"

    When I follow "View Staged"
    And I should see 10 search results

    When I go to the "new aff site" affiliate page
    And I follow "View Current"
    Then I should see "Sorry, no results found"

    When I go to the "new aff site" affiliate page
    And I follow "Site information"
    Then the "HTTP parameter site name" field should contain "aff.gov"

    When I go to the "new aff site" affiliate page
    And I press "Push Changes"
    And I go to the "new aff site" affiliate page
    And I follow "View Current"
    Then I should see 10 search results

  Scenario: Editing site information with problem and saving it for preview
    Given the following Affiliates exist:
      | display_name     | name            | domains       | contact_email         | contact_name        |
      | aff site         | aff.gov         | example.org   | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Site information"
    And I fill in the following:
      | Site name                  |                     |
      | Site URL                   |                     |
      | Domains to search          |                     |
    And I press "Save for Preview"
    Then I should see "Site Information" within "title"
    And I should see "Site name can't be blank"

  Scenario: Editing site information and make it live
    Given the following Affiliates exist:
      | display_name     | name            | domains       | contact_email         | contact_name        |
      | aff site         | aff.gov         | example.org   | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Site information"
    And I fill in the following:
      | Site name                  | new aff site        |
      | Site URL                   | www.aff.gov         |
      | Domains to search          | data.gov            |
    And I press "Make Live"
    Then I should be on the "new aff site" affiliate page
    And I should see "Updated changes to your live site successfully"
    And I should see "Site: new aff site"
    And I should see "www.aff.gov"
    And I should not see "View Staged"

    When I follow "View Current"
    Then I should see 10 search results

   Scenario: Editing site information with problem and make it live
    Given the following Affiliates exist:
      | display_name     | name            | domains       | contact_email         | contact_name        |
      | aff site         | aff.gov         | example.org   | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Site information"
    And I fill in the following:
      | Site name                  |                     |
      | Site URL                   |                     |
      | Domains to search          |                     |
    And I press "Make Live"
    Then I should see "Site Information" within "title"
    And I should see "Site name can't be blank"

  Scenario: Editing site information where staged/live domains are not sync and has_staged_content is false
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     | affiliate_template_name | search_results_page_title     | domains        | header      | footer      | staged_affiliate_template_name | staged_search_results_page_title   | staged_domains   | staged_header    | staged_footer  | has_staged_content |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar         | Default                 | Live Search Results           | data.gov       | Live header | Live footer | Basic Gray                     | Staged Search Results              | stagedagency.gov | Staged header    | Staged footer  | false              |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Site information"
    Then the "Domains to search" field should contain "data.gov"
    When I press "Save for Preview"
    Then I should be on the "aff site" affiliate page
    And I should see "Staged changes to your site successfully"
    When I follow "View Staged"
    Then I should see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should see 10 search results
    And I should see "Live Search Results"
    And I should see "Live header"
    And I should see "Live footer"

  Scenario: Editing site information where staged/live domains are not sync and has_staged_content is true
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     | affiliate_template_name | search_results_page_title     | domains        | header      | footer      | staged_affiliate_template_name | staged_search_results_page_title   | staged_domains   | staged_header    | staged_footer  | has_staged_content |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar         | Default                 | Live Search Results           | data.gov       | Live header | Live footer | Basic Gray                     | Staged Search Results              | stagedagency.gov | Staged header    | Staged footer  | true               |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Site information"
    Then the "Domains to search" field should contain "stagedagency.gov"
    When I press "Save for Preview"
    Then I should be on the "aff site" affiliate page
    And I should see "Staged changes to your site successfully"
    When I follow "View Staged"
    Then I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with affiliate stylesheet "default"
    And I should see "Sorry, no results found"
    And I should see "Staged Search Results"
    And I should see "Staged header"
    And I should see "Staged footer"

  Scenario: Visiting the look and feel page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     | search_results_page_title               | domains        | header      | footer      | staged_domains  | staged_header    | staged_footer  |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar         | {Query} - {SiteName} Search Results     | oldagency.gov  | Old header  | Old footer  | oldagency.gov    | Old header      | Old footer     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Look and Feel of the Search Results Page
    And I should see "Look and Feel of the Search Results Page" within ".main"
    And the "Search results page title" field should contain "\{Query\} - \{SiteName\} Search Results"
    And the "Default" template should be selected
    And the "Enter HTML to customize the top of your search results page." field should contain "Old header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "Old footer"
    And I should see "Cancel"
    When I follow "Cancel"
    Then I should be on the "aff site" affiliate page

  Scenario: Editing look and feel and saving it for preview
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     | search_results_page_title               | domains        | header      | footer      | staged_domains  | staged_header    | staged_footer  |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar         | {Query} - {SiteName} Search Results     | oldagency.gov  | Old header  | Old footer  | oldagency.gov    | Old header      | Old footer     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                         | {SiteName} : {Query} |
      | Enter HTML to customize the top of your search results page.      | New header           |
      | Enter HTML to customize the bottom of your search results page.   | New footer           |
    And I choose "Basic Gray"
    And I press "Save for Preview"
    Then I should be on the "aff site" affiliate page
    And I should see "Staged changes to your site successfully"

    When I follow "View Current"
    Then I should see "gov - aff site Search Results"
    And I should see "Old header"
    And I should see "Old footer"
    And I should see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with affiliate stylesheet "default"

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    And I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with affiliate stylesheet "default"

  Scenario: Editing look and feel with problem and saving it for preview
    Given the following Affiliates exist:
      | display_name     | name            | domains       | contact_email         | contact_name        |
      | aff site         | aff.gov         | example.org   | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                         |     |
    And I press "Save for Preview"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see "Search results page title can't be blank"

  Scenario: Editing look and feel and make it live
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     | search_results_page_title               | domains        | header      | footer      | staged_domains  | staged_header    | staged_footer  |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar         | {Query} - {SiteName} Search Results     | oldagency.gov  | Old header  | Old footer  | oldagency.gov    | Old header      | Old footer     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                         | {SiteName} : {Query} |
      | Enter HTML to customize the top of your search results page.      | New header           |
      | Enter HTML to customize the bottom of your search results page.   | New footer           |
    And I choose "Basic Gray"
    And I press "Make Live"
    Then I should be on the "aff site" affiliate page
    And I should see "Updated changes to your live site successfully"
    And I should not see "View Staged"

    When I follow "View Current"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with affiliate stylesheet "default"

  Scenario: Editing look and feel with problem and make it live
    Given the following Affiliates exist:
      | display_name     | name            | domains       | contact_email         | contact_name        |
      | aff site         | aff.gov         | example.org   | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                         |     |
    And I press "Make Live"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see "Search results page title can't be blank"

  Scenario: Editing look and feel where staged/live domains are not sync and has_staged_content is false
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     | affiliate_template_name | search_results_page_title     | domains        | header      | footer      | staged_affiliate_template_name | staged_search_results_page_title   | staged_domains   | staged_header    | staged_footer  | has_staged_content |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar         | Default                 | Live Search Results           | data.gov       | Live header | Live footer | Basic Gray                     | Staged Search Results              | stagedagency.gov | Staged header    | Staged footer  | false              |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Search results page title" field should contain "Live Search Results"
    And the "Default" template should be selected
    And the "Enter HTML to customize the top of your search results page." field should contain "Live header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "Live footer"
    When I press "Save for Preview"
    Then I should be on the "aff site" affiliate page
    And I should see "Staged changes to your site successfully"
    When I follow "View Staged"
    Then I should see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should see "Live Search Results"
    And I should see 10 search results
    And I should see "Live header"
    And I should see "Live footer"

  Scenario: Editing look and feel where staged/live domains are not sync and has_staged_content is true
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     | affiliate_template_name | search_results_page_title     | domains        | header      | footer      | staged_affiliate_template_name | staged_search_results_page_title   | staged_domains   | staged_header    | staged_footer  | has_staged_content |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar         | Default                 | Live Search Results           | data.gov       | Live header | Live footer | Basic Gray                     | Staged Search Results              | stagedagency.gov | Staged header    | Staged footer  | true               |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Search results page title" field should contain "Staged Search Results"
    And the "Basic Gray" template should be selected
    And the "Enter HTML to customize the top of your search results page." field should contain "Staged header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "Staged footer"
    When I press "Save for Preview"
    Then I should be on the "aff site" affiliate page
    And I should see "Staged changes to your site successfully"
    When I follow "View Staged"
    Then I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with affiliate stylesheet "default"
    And I should see "Staged Search Results"
    And I should see "Sorry, no results found"
    And I should see "Staged header"
    And I should see "Staged footer"

  Scenario: Cancelling staged changes from the Affiliate Center page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | has_staged_content | header     | staged_header |
      | foo site         | multifoo.gov     | two@bar.gov           | Two Bar             | true               | old header | new header    |
    And I am logged in with email "two@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I press "Cancel Changes"
    Then I should be on the "foo site" affiliate page
    And I should see "Staged changes were successfully cancelled."
    And I should not see "View Staged"
    And I should not see "Push Changes" button
    And I should not see "Cancel Changes" button
    When I follow "View Current"
    Then I should see "old header"

  Scenario: Cancelling staged changes from the site specific Affiliate Center page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     | search_results_page_title               | domains        | header      | footer      | staged_domains  | staged_header    | staged_footer  |
      | foo site         | aff.gov          | aff@bar.gov           | John Bar         | {Query} - {SiteName} Search Results     | data.gov       | Old header  | Old footer  | data.gov        | Old header       | Old footer     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "foo site" affiliate page
    And I follow "Site information"
    And I fill in "Domains to search" with "invalid.org"
    And I press "Save for Preview"
    Then I should see "Staged changes to your site successfully"
    And I should see "Cancel Changes" button
    When I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                         | updated SERP title  |
      | Enter HTML to customize the top of your search results page.      | New header          |
      | Enter HTML to customize the bottom of your search results page.   | New footer          |
    And I choose "Basic Gray"
    And I press "Save for Preview"
    And I should see "Staged changes to your site successfully"
    Then I should see "Cancel Changes" button
    When I follow "View Staged"
    Then I should see the page with affiliate stylesheet "basic_gray"
    And I should see "updated SERP title"
    And I should see "New header"
    And I should see "New footer"
    And I should see "Sorry, no results found"

    When I go to the "foo site" affiliate page
    And I press "Cancel Changes"
    Then I should be on the "foo site" affiliate page
    And I should see "Staged changes were successfully cancelled."
    And I should not see "View Staged"
    And I should not see "Push Changes" button
    And I should not see "Cancel Changes" button
    When I follow "View Current"
    Then I should see the page with affiliate stylesheet "default"
    And I should see "gov - foo site Search Results"
    And I should see "Old header"
    And I should see "Old footer"
    And I should see 10 search results

  Scenario: Cancelling staged changes from the Preview page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | has_staged_content | header     | staged_header |
      | foo site         | multifoo.gov     | two@bar.gov           | Two Bar             | true               | old header | new header    |
    And I am logged in with email "two@bar.gov" and password "random_string"
    When I go to the "foo site" affiliate page
    And I follow "Preview"
    And I press "Cancel Staged Changes"
    Then I should be on the "foo site" affiliate page
    And I should see "Staged changes were successfully cancelled."
    And I should not see "View Staged"
    And I should not see "Push Changes" button
    And I should not see "Cancel Changes" button
    When I follow "View Current"
    Then I should see "old header"

  Scenario: Visiting the preview page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name     |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Preview"
    Then I should see "Preview" within "title"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Preview
    And I should see "Preview" within "h1"
    And I should see "Search on Live Site" button
    And I should not see "Preview Search on Staged Site" button

    When I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                   | Staged - {SiteName} : {Query} |
    And I press "Save for Preview"
    And I follow "Preview"
    And I fill in the following within "#staged_site_search_form":
      | query | White House |
    And I press "Preview Search on Staged Site"
    Then I should see "Staged - aff site : White House" within "title"

    When I go to the "aff site" affiliate page
    And I follow "Preview"
    And I fill in the following within "#live_site_search_form":
      | query | White House |
    And I press "Search on Live Site"
    Then I should see "White House - aff site Search Results"

    When I go to the "aff site" affiliate page
    And I follow "Preview"
    And I press "Make Live"
    Then I should be on the "aff site" affiliate page
    And I should see "Staged content is now visible"
    And I follow "Preview"
    And I fill in the following within "#live_site_search_form":
      | query | White House |
    And I press "Search on Live Site"
    Then I should see "Staged - aff site : White House" within "title"

  Scenario: Related Topics on English SERPs for given affiliate search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following Calais Related Searches exist for affiliate "aff.gov":
      | term    | related_terms             | locale |
      | obama   | Some Unique Related Term  | en     |
    When I go to aff.gov's search page
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should see "Related Topics" in the left column
    And I should not see "Related Topics" in the search results section
    And I should see "Some Unique Related Term"
    And I should not see "aff.gov"

  Scenario: Affiliate SAYT
    Given the following Affiliates exist:
      | display_name      | name            | contact_email             | contact_name          | domains        | is_sayt_enabled | is_affiliate_suggestions_enabled |
      | aff site          | aff.gov           | aff@bar.gov             | John Bar              | usa.gov        | true            | false                            |
      | other site        | otheraff.gov      | otheraff@bar.gov        | Other John Bar        | usa.gov        | false           | false                            |
      | another site      | anotheraff.gov    | anotheraff@bar.gov      | Another John Bar      | usa.gov        | true            | true                             |
      | yet another site  | yetanotheraff.gov | yetanotheraff@bar.gov   | Yet Another John Bar  | usa.gov        | false           | true                             |
    When I go to aff.gov's search page
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "aff.gov" should be disabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "aff.gov" should be disabled

    When I go to otheraff.gov's search page
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "otheraff.gov" should be disabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "otheraff.gov" should be disabled

    When I go to anotheraff.gov's search page
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "anotheraff.gov" should be enabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "anotheraff.gov" should be enabled

    When I go to yetanotheraff.gov's search page
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "yetanotheraff.gov" should be disabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "yetanotheraff.gov" should be disabled

  Scenario: Visiting an affiliate search page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email            | contact_name        | has_staged_content |
      | noindex site     | noindex.gov      | aff@aff.gov              | Two Bar             | true               |
    When I go to noindex.gov's search page
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag

  Scenario: Visiting an affiliate advanced search page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email            | contact_name        | has_staged_content |
      | noindex site     | noindex.gov      | aff@aff.gov              | Two Bar             | true               |
    When I go to noindex.gov's search page
    And I follow "Advanced Search"
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see the browser page titled "Advanced Search - noindex site"

  Scenario: Visiting an affiliate Spanish advanced search page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email            | contact_name        | has_staged_content |
      | noindex site     | noindex.gov      | aff@aff.gov              | Two Bar             | true               |
    When I go to noindex.gov's Spanish search page
    And I follow "Búsqueda avanzada"
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see the browser page titled "Búsqueda avanzada - noindex site"

  Scenario: Doing an advanced affiliate search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | domains        | header                | footer                |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            | usa.gov        | Affiliate Header      | Affiliate Footer      |
    When I go to aff.gov's search page
    And I follow "Advanced Search"
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see "Header"
    And I should see "Footer"
    And I should see "Use the options on this page to create a very specific search"
    And I should not see "aff.gov"
    When I fill in "query" with "emergency"
    And I press "Search"
    Then I should see "Results 1-10"
    And I should see "emergency"

    When I go to aff.gov's Spanish search page
    And I follow "Búsqueda avanzada"
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see "Header"
    And I should see "Footer"
    And I should see "Use las siguientes opciones para hacer una búsqueda específica."
    And I should not see "aff.gov"
    When I fill in "query" with "emergency"
    And I press "Busque información del Gobierno"
    Then I should see "Resultados 1-10"
    And I should see "emergency"

    When I am on the affiliate advanced search page for "aff.gov"
    And I fill in "query-or" with "barack obama"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "barack OR obama"

    When I am on the affiliate advanced search page for "aff.gov"
    And I fill in "query-quote" with "barack obama"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "barack obama"

    When I am on the affiliate advanced search page for "aff.gov"
    And I fill in "query-not" with "barack"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "-barack"

    When I am on the affiliate advanced search page for "aff.gov"
    And I select "Adobe PDF" from "filetype"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "filetype:pdf"

    When I am on the affiliate advanced search page for "aff.gov"
    And I fill in "query" with "barack obama"
    And I select "20" from "per-page"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "Results 1-20"

    When I am on the affiliate advanced search page for "aff.gov"
    And I choose "Off"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should not see "Sorry, no results found"

  Scenario: Getting an embed code for my affiliate site search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Get code"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Get Code
    And I should see "The following is the HTML code for your search box form. Copy and paste this code into your page(s) where the search box should appear."
    And I should see "Code for English-language sites"
    And I should see "Code for Spanish-language sites"
    And I should see "Do you want to have Type-ahead Search box on your home page and/or in your banner?"
    And I should see "How To Implement Type-ahead Search"
    When I follow "Type-ahead Search" within ".cross-promotion"
    Then I should see "Add a New Entry"
    And I should not see "aff.gov"

  Scenario: Navigating to an Affiliate page for a particular Affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "aff site"
    Then I should see "Site: aff site" within "title"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Site: aff site" within ".main"
    And I should see "Delete Site" button
    And I should see "Site information" in the site navigation bar
    And I should see "Add new site" in the site navigation bar
    And I should see "My account" in the site navigation bar
    And I should see "Manage users" in the site navigation bar
    And I should not see "aff.gov"

    When I follow "My account" in the site navigation bar
    Then I should be on the user account page"

  Scenario: Stats link on affiliate home page
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there is analytics data for affiliate "aff.gov" from "20100401" thru "20100415"
    When I go to the affiliate admin page with "aff.gov" selected
    Then I should see "Site Analytics"

  Scenario: Getting stats for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there is analytics data for affiliate "aff.gov" from "20100401" thru "20100415"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query logs"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Query Analytics
    And I should see "Query Logs for aff site"
    And I should not see "aff.gov"
    And I should see "Most Frequent Queries"
    And I should see "Data for April 15, 2010"
    And I should not see "No queries matched"

  Scenario: No daily query stats available for any time period
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there are no daily query stats
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query logs"
    Then in "dqs1" I should see "Not enough historic data"
    And in "dqs7" I should see "Not enough historic data"
    And in "dqs30" I should see "Not enough historic data"

  Scenario: Viewing Query Search page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And the following DailyQueryStats exist:
      | query                       | times | affiliate     | locale |   days_back   |
      | pollution                   | 100   | aff.gov       | en     |      1        |
      | old pollution               | 10    | aff.gov       | en     |      30       |
      | pollutant                   | 90    | usasearch.gov | en     |      1        |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query logs"
    And I fill in "query" with "pollution"
    And I fill in "analytics_search_start_date" with a date representing "29" days ago
    And I fill in "analytics_search_end_date" with a date representing "1" day ago
    And I press "Search"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Query Search
    And I should see "Matches for 'pollution'"
    And I should not see "Matches for 'old pollution'"
    And I should not see "Matches for 'pollutant'"
    And I should not see "aff.gov"

  Scenario: Viewing the Affiliates Monthly Reports page
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
     | aff2 site        | aff2.gov         | aff@bar.gov             | John Bar            |
    And the following DailyUsageStats exists for each day in yesterday's month
    | profile     | total_queries | affiliate |
    | Affiliates  | 1000          | aff.gov   |
    And the following DailySearchModuleStats exist for each day in yesterday's month
      | affiliate         | total_clicks |
      | aff.gov           | 10           |
      | aff2.gov          | 5            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly reports"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Monthly Reports
    And I should see "Monthly Reports for aff site"
    And I should see "Monthly Usage Stats"
    And I should not see "aff.gov"
    And I should see the header for the report date
    And I should see the "aff site" queries total within "aff.gov_usage_stats"
    And I should see the "aff site" clicks total within "aff.gov_usage_stats"

  Scenario: Viewing the Affiliates Monthly Reports page for a month in the past
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
     | aff2 site        | aff2.gov         | aff@bar.gov             | John Bar            |
    And the following DailyUsageStats exist for each day in "2010-02"
     | profile | total_queries  | affiliate  |
     | Affiliates | 1000        | aff.gov    |
    And the following DailySearchModuleStats exist for each day in "2010-02"
      | affiliate         | total_clicks |
      | aff.gov           | 10           |
      | aff2.gov          | 5            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly reports"
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then I should see the report header for "2010-02"
    And I should see the "aff site" "Queries" total within "aff.gov_usage_stats" with a total of "28,000"
    And I should see the "aff site" "Click Throughs" total within "aff.gov_usage_stats" with a total of "280"

  Scenario: Viewing the Affiliates Monthly Reports page for a month in the future
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And the following DailyUsageStats exist for each day in "2019-02"
     | profile    | total_queries   | affiliate  |
     | Affiliates | 1000            | aff.gov    |
    And the following DailySearchModuleStats exist for each day in "2019-02"
      | affiliate         | total_clicks |
      | aff.gov           | 10           |
      | aff2.gov          | 5            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly reports"
    And I select "December 2011" as the report date
    And I press "Get Usage Stats"
    Then I should see "Report information not available for the future."

  Scenario: Viewing SAYT Suggestions for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead search"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Type-ahead Search
    And I should not see "aff.gov"

  Scenario: Setting SAYT Preferences for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead search"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Preferences"
    And the "sayt_preferences_disable" button should be checked

    When I choose "sayt_preferences_enable_affiliate"
    And I press "Set Preferences"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Preferences updated"
    And the "sayt_preferences_enable_affiliate" button should be checked
    And the affiliate "aff.gov" should be set to use affiliate SAYT

    When I choose "sayt_preferences_enable_global"
    And I press "Set Preferences"
    Then I should be on the affiliate sayt page for "aff.gov"
    And the "sayt_preferences_enable_global" button should be checked
    And the affiliate "aff.gov" should be set to use global SAYT

    When I choose "sayt_preferences_disable"
    And I press "Set Preferences"
    Then I should be on the affiliate sayt page for "aff.gov"
    And the "sayt_preferences_disable" button should be checked
    And the affiliate "aff.gov" should be disabled

  Scenario: Adding and removing a SAYT Suggestion to an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        | is_sayt_enabled | is_affiliate_suggestions_enabled |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            | true            | true                             |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead search"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Add a New Entry"
    When I fill in "Phrase" with "banana"
    And I press "Add"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Successfully added: banana"
    And I should see "banana" within "#sayt-suggestions"

    When I fill in "Phrase" with "banana"
    And I press "Add"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Unable to add: banana"

    When I press "Delete"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Deleted phrase: banana"
    And I should not see "banana" within "#sayt-suggestions"

  Scenario: Adding a misspelled SAYT Suggestion to an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        | is_sayt_enabled | is_affiliate_suggestions_enabled |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            | true            | true                             |
    Given the following Misspelling exist:
      | wrong    | rite    |
      | haus     | house   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead search"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Add a New Entry"
    When I fill in "Phrase" with "haus"
    And I press "Add"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Successfully added: haus"
    And I should see "haus" within "#sayt-suggestions"

  Scenario: Uploading SAYT Suggestions for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        | is_sayt_enabled | is_affiliate_suggestions_enabled |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            | true            | true                             |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead search"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Bulk Upload"

    When I attach the file "features/support/sayt_suggestions.txt" to "txtfile"
    And I press "Upload"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "5 Type-ahead Search suggestions uploaded successfully"

    When I attach the file "features/support/sayt_suggestions.txt" to "txtfile"
    And I press "Upload"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "5 Type-ahead Search suggestions ignored"

    When I attach the file "features/support/cant_read_this.doc" to "txtfile"
    And I press "Upload"
    Then I should be on the affiliate sayt page for "aff.gov"
    And I should see "Your file could not be processed."

  Scenario: Viewing Related Topics for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Related topics"
    Then I should be on the affiliate related topics page for "aff.gov"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Related Topics
    And I should not see "aff.gov"
    When I follow "Preview Button"
    Then I should be on the preview affiliate page for "aff.gov"

  Scenario: Setting Related Topics Preferences for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Related topics"
    Then I should be on the affiliate related topics page for "aff.gov"
    And I should see "Preferences"
    And the "related_topics_setting_affiliate_enabled" button should be checked

    When I choose "related_topics_setting_global_enabled"
    And I press "Set Preferences"
    Then I should be on the affiliate related topics page for "aff.gov"
    And the "related_topics_setting_global_enabled" button should be checked
    And the affiliate "aff.gov" should be set to use global related topics

    When I choose "related_topics_setting_affiliate_enabled"
    And I press "Set Preferences"
    Then I should be on the affiliate related topics page for "aff.gov"
    And I should see "Preferences updated"
    And the "related_topics_setting_affiliate_enabled" button should be checked
    And the affiliate "aff.gov" should be set to use affiliate related topics

    When I choose "related_topics_setting_disabled"
    And I press "Set Preferences"
    Then I should be on the affiliate related topics page for "aff.gov"
    And the "related_topics_setting_disabled" button should be checked
    And the affiliate "aff.gov" related topics should be disabled

  Scenario: Viewing Manage Users for an affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Manage users"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Manage Users
    And I should see "Manage Users"
    And I should see "John Bar (aff@bar.gov)"
    And I should see "My Account"
    And I should not see "aff.gov"

  Scenario: Adding an existing user to an affiliate
    Given the following Users exist:
      | contact_name  | email             |
      | Existing User | existing@usa.gov  |
    And the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And no emails have been sent
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Manage users"
    And I fill in "Email" with "existing@usa.gov"
    And I fill in "Name" with "Existing User"
    And I press "Add User"
    When "existing@usa.gov" opens the email
    And I should see "Dear Existing User" in the email body
    And I should see "You have been successfully added to aff site by John Bar" in the email body

  Scenario: Adding a new user to an affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And no emails have been sent
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Manage users"
    And I fill in "Email" with "newuser@usa.gov"
    And I fill in "Name" with "New User"
    And I press "Add User"
    Then I should see "That user does not exist in the system."
    When I follow "Sign Out"
    Then I should be on the login page
    When "newuser@usa.gov" opens the email with text "Welcome to the USASearch Affiliate Program"
    Then I should see "Welcome to the USASearch Affiliate Program" in the email subject
    And I should see "Dear New User" in the email body
    And I should see "You have been successfully registered and added to aff site by John Bar with the following account information." in the email body
    When I click the first link in the email
    Then I should see "Complete Registration for a New Account"
    And the "Name*" field should contain "New User"
    And the "Email*" field should contain "newuser@usa.gov"
    And the "I have read and accept the" checkbox should not be checked
    When I fill in the following:
      | Password                      | huge_secret                 |
      | Password confirmation         | huge_secret                 |
    And I check "I have read and accept the"
    And I press "Complete registration for a new account"
    Then I should be on the affiliate admin page
    And I should see "You have successfully completed your account registration."

  Scenario: Failed to complete registration
    Given the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Manage users"
    And I fill in "Email" with "newuser@usa.gov"
    And I fill in "Name" with "New User"
    And I press "Add User"
    And I follow "Sign Out"
    When "newuser@usa.gov" opens the email with text "Welcome to the USASearch Affiliate Program"
    Then I should see "Welcome to the USASearch Affiliate Program" in the email subject
    When I click the first link in the email
    Then I should see "Complete Registration for a New Account"
    And the "Name*" field should contain "New User"
    And the "Email*" field should contain "newuser@usa.gov"
    And the "I have read and accept the" checkbox should not be checked
    When I fill in the following:
      | Name             |                  |
      | Email            |                  |
    And I press "Complete registration for a new account"
    Then I should see "Contact name can't be blank"
    And I should see "Email can't be blank"
    And I should see "Email should look like an email address"
    And I should see "Password is too short"
    And I should see "Password confirmation is too short"
    And I should see "Password doesn't match confirmation"
    And I should see "Terms of service must be accepted"

  Scenario: Adding a new user to a site without filling out the form
    Given the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Manage users"
    And I press "Add User"
    Then I should see "Email can't be blank"
    And I should see "Contact name can't be blank"

  Scenario: A nonsense affiliate search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email     | contact_name        | affiliate_template_name |
      | aff site         | aff.gov          | aff@bar.gov       | John Bar            | Default                 |
    When I go to aff.gov's search page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I press "Search"
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Visiting the affiliate search page with popular urls
    Given the following Affiliates exist:
      | display_name     | name             | contact_email     | contact_name        | affiliate_template_name |
      | aff site         | aff.gov          | aff@bar.gov       | John Bar            | Default                 |
      | another site     | another.gov      | aff@another.gov   | Jane Doe            | Default                 |
    And the following popular URLs exist:
      | affiliate_name   | title                                                                                                  | url                              | rank   |
      | aff.gov          | Awesome sixth blog post                                                                                | http://awesome.gov/blog/6        | 6      |
      | aff.gov          | Awesome fourth blog post                                                                               | http://awesome.gov/blog/4        | 4      |
      | aff.gov          | Awesome fifth blog post                                                                                | http://awesome.gov/blog/5        | 5      |
      | aff.gov          | Awesome third blog post                                                                                | http://awesome.gov/blog/3        | 3      |
      | aff.gov          | Space, NASA Information & News, Outer Space Flight Videos & Pictures - Astronomy, Solar System Images | http://awesome.gov/blog/1        | 1      |
      | aff.gov          | Awesome second blog post                                                                               | http://awesome.gov/blog/2        | 2      |
    When I go to aff.gov's search page
    Then I should see 3 popular URLs
    And I should not see a link to "Space, NASA Information & News, Outer Space..."
    And I should not see a link to "Awesome second blog post"
    And I should not see a link to "Awesome third blog post"
    And I should see a link to "Awesome fourth blog post" with url for "http://awesome.gov/blog/4" in the popular urls section
    And I should see a link to "Awesome fifth blog post" with url for "http://awesome.gov/blog/5" in the popular urls section
    And I should see a link to "Awesome sixth blog post" with url for "http://awesome.gov/blog/6" in the popular urls section

  Scenario: Embedded affiliate search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | header           | footer           |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | Affiliate Header | Affiliate Footer |
    When I go to aff.gov's embedded search page
    Then I should not see "Affiliate Header"
    And I should not see "Affiliate Footer"
    When I fill in "query" with "weather"
    And I press "Search"
    Then I should not see "Affiliate Header"
    And I should not see "Affiliate Footer"

 Scenario: Embedded advanced affiliate search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | header           | footer           |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | Affiliate Header | Affiliate Footer |
    When I go to aff.gov's embedded search page
    And I follow "Advanced Search"
    And I press "Search"
    Then I should not see "Affiliate Header"
    And I should not see "Affiliate Footer"

  Scenario: Affiliate without exclude webtrends
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    When I go to aff.gov's search page
    Then I should see the page with Webtrends tag

 Scenario: Affiliate with exclude webtrends
   Given the following Affiliates exist:
     | display_name | name    | contact_email | contact_name | exclude_webtrends |
     | aff site     | aff.gov | aff@bar.gov   | John Bar     | true              |
   When I go to aff.gov's search page
   Then I should not see the page with Webtrends tag

