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
    And I should see "Affiliate Center" within ".main"
    And I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    And I should not see a link to "Mobile" in the connect section
    And I should not see a link to "Share" in the connect section
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
    And I should not see "Custom"
    When I fill in the following:
      | Site name         | My awesome agency                    |
      | Domain 0          | agency.gov                           |
      | Facebook handle   | FBAgency                             |
      | Flickr URL        | http://www.flickr.com/groups/usagov/ |
      | Twitter handle    | TwitterAgency                        |
      | YouTube handle    | YouTubeAgency                        |
    And I choose "Gettysburg"
    And I press "Next"
    Then I should see "Add a New Site" within "title"
    And I should see "Site successfully created"
    And I should see "Step 3. Get the code" in the site wizards header
    And I should see the code for English language sites
    And I should see "View search results page"
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should see "White House - My awesome agency Search Results"
    When I go to the "My awesome agency" affiliate page
    And I follow "Site information"
    Then the "Site name" field should contain "My awesome agency"
    When I follow "Look and feel"
    Then the "Gettysburg" theme should be selected
    And the "Left tab text color" field should contain "#C71D2E"
    And the "Left tab text color" field should be disabled
    And the "Title link color" field should contain "#336699"
    And the "Title link color" field should be disabled
    And the "Visited title link color" field should contain "#8F5576"
    And the "Visited title link color" field should be disabled
    And the "Description text color" field should contain "#595959"
    And the "Description text color" field should be disabled
    And the "URL link color" field should contain "#007F00"
    And the "URL link color" field should be disabled
    When I follow "Domains"
    Then I should see the following table rows:
      | Site Name       | Domain         |
      | agency.gov      | agency.gov     |
    When I follow "Social Media"
    Then the "Facebook handle" field should contain "FBAgency"
    And the "Flickr URL" field should contain "http://www.flickr.com/groups/usagov/"
    And the "Twitter handle" field should contain "TwitterAgency"
    And the "YouTube handle" field should contain "YouTubeAgency"

    When I go to myawesomeagency's search page
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see the affiliate custom css

  Scenario: Adding a new Spanish affiliate
    Given I am logged in with email "affiliate_with_no_contact_info@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I fill in the following:
      | Government organization                    | Awesome Agency             |
      | Phone                                      | 202-123-4567               |
      | Organization address                       | 123 Penn Avenue            |
      | Address 2                                  | Ste 456                    |
      | City                                       | Reston                     |
      | Zip                                        | 20022                      |
    And I select "Virginia" from "State"
    And I press "Next"
    When I fill in the following:
      | Site name         | My awesome agency                    |
    And I choose "Spanish"
    And I press "Next"
    Then I should see the code for Spanish language sites
    And I should see "View search results page"
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should see "White House - My awesome agency Search Results"
    And I should see "Búsqueda avanzada"
    When I go to the "My awesome agency" affiliate page
    And I follow "Site information"
    Then the "Spanish" checkbox should be checked

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

  Scenario: Adding an affiliate without valid site information should fail
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    And I fill in "Domain 0" with "notavaliddomain"
    And I press "Next"
    Then I should see "Site name can't be blank"
    And I should see "Domain is invalid"
    And I should not see "Site Handle (visible to searchers in the URL) can't be blank"
    And I should not see "Site Handle (visible to searchers in the URL) is too short"
    And I should not see "Site Handle (visible to searchers in the URL) is invalid"

    When I fill in the following:
      | Site name | My awesome agency |
      | Domain 0  | www1.mydomain.gov |
      | Domain 1  | www2.mydomain.gov |
    And I press "Next"
    And I should see "Site successfully created"

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

  Scenario: Visiting the site specific Affiliate Center
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I should see the following table row:
      | Site name |
      | aff site  |

  Scenario: Visiting the site information page
    Given the following Affiliates exist:
      | display_name | name    | domains     | contact_email | contact_name |
      | aff site     | aff.gov | example.org | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Site information"
    Then I should see "Site Information" within "title"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Site Information
    And I should see "Site Information" within ".main"
    And the "Site name" field should contain "aff site"
    And the "Site Handle (visible to searchers in the URL)" field should contain "aff.gov"
    And I should see "Cancel"
    When I follow "Cancel"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site

  Scenario: Editing site information and saving it
    Given the following Affiliates exist:
      | display_name | name    | domains     | contact_email | contact_name |
      | aff site     | aff.gov | example.org | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Site information"
    And I fill in the following:
      | Site name | new aff site |
    And I press "Save"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > new aff site
    And I should see "Site was successfully updated."
    And I should see "Site: new aff site"

    When I follow "View Current"
    Then I should see the browser page titled "gov - new aff site Search Results"

  Scenario: Editing site information with problem and saving it
    Given the following Affiliates exist:
      | display_name | name    | domains     | contact_email | contact_name |
      | aff site     | aff.gov | example.org | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Site information"
    And I fill in the following:
      | Site name |  |
    And I press "Save"
    Then I should see "Site Information" within "title"
    And I should see "Site name can't be blank"

  Scenario: Visiting the look and feel page on a site with one serp
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | header_footer_css                                          | header     | footer     | favicon_url                | external_css_url          | uses_one_serp | theme   |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | #current_header {color:blue;} #current_footer {color:red;} | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | true          | default |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Look and Feel of the Search Results Page
    And I should see "Look and Feel of the Search Results Page" within ".main"
    And the "Search results page title" field should contain "\{Query\} - \{SiteName\} Search Results"
    And the "Favicon URL" field should contain "cdn.agency.gov/favicon.ico"
    And the "Font family" field should contain "Arial, sans-serif"
    And the "Liberty Bell" theme should be selected
    And the "Custom" theme should not be visible
    And the "Left tab text color" field should contain "#9E3030"
    And the "Title link color" field should contain "#2200CC"
    And the "Visited title link color" field should contain "#800080"
    And the "Description text color" field should contain "#000000"
    And the "URL link color" field should contain "#008000"
    And the "External CSS URL" field should contain "http://cdn.agency.gov/custom.css"
    And the "Enter CSS to customize the top and bottom of your search results page." field should contain "#current_header \{color:blue;\} #current_footer \{color:red;\}"
    And the "Enter HTML to customize the top of your search results page." field should contain "Old header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "Old footer"
    And I should not see "Template"
    And I should see "Cancel"
    When I follow "Cancel"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site

  Scenario: Visiting the look and feel page on a site with legacy template
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | header     | footer     | favicon_url                | external_css_url          | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Look and Feel of the Search Results Page
    And I should see "Look and Feel of the Search Results Page" within ".main"
    And the "Search results page title" field should contain "\{Query\} - \{SiteName\} Search Results"
    And the "Default" template should be selected
    And the "Favicon URL" field should contain "cdn.agency.gov/favicon.ico"
    And the "External CSS URL" field should contain "http://cdn.agency.gov/custom.css"
    And the "Enter HTML to customize the top of your search results page." field should contain "Old header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "Old footer"
    And I should not see "Title link color"
    And I should not see "Visited title link color"
    When I follow "Cancel"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site

  Scenario: Visiting the look and feel page for affiliate without external_css_url
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then I should not see a field labeled "External CSS URL"

  Scenario: Visiting the look and feel page for affiliate with staged_external_css_url
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | staged_external_css_url          | has_staged_content |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | cdn.agency.gov/staged_custom.css | true               |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "External CSS URL" field should contain "http://cdn.agency.gov/staged_custom.css"

  Scenario: Editing look and feel and saving it for preview on a site with one serp
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | header_footer_css            | header     | footer     | favicon_url                | external_css_url          | uses_one_serp | theme  |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #009000        | .current h1 { color: blue; } | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | true          | custom |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    Then the "Font family" field should contain "Verdana, sans-serif"
    And the "Custom" theme should be selected
    And the "Custom" theme should be visible
    And the "Left tab text color" field should contain "#BBBBBB"
    And the "Title link color" field should contain "#33ff33"
    And the "Visited title link color" field should contain "#0000ff"
    And the "Description text color" field should contain "#CCCCCC"
    And the "URL link color" field should contain "#009000"
    When I fill in the following:
      | Search results page title                                              | {SiteName} : {Query}              |
      | Favicon URL                                                            | cdn.agency.gov/staged_favicon.ico |
      | Left tab text color                                                    | #AAAAAA                           |
      | Title link color                                                       | #888888                           |
      | Visited title link color                                               | #0000f0                           |
      | Description text color                                                 | #DDDDDD                           |
      | URL link color                                                         | #007000                           |
      | External CSS URL                                                       | cdn.agency.gov/staged_custom.css  |
      | Enter CSS to customize the top and bottom of your search results page. | .staged h1 { color: green; }      |
      | Enter HTML to customize the top of your search results page.           | New header                        |
      | Enter HTML to customize the bottom of your search results page.        | New footer                        |
    And I select "Helvetica, sans-serif" from "Font family"
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Staged changes to your site successfully"

    When I follow "View Current"
    Then I should see "gov - aff site Search Results"
    And I should see "Old header"
    And I should see "Old footer"
    And I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with internal CSS ".header-footer .current h1\{color:blue\}"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"
    And I should not see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with internal CSS ".header-footer .staged h1\{color:green\}"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"

    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Font family" field should contain "Helvetica, sans-serif"
    And the "Left tab text color" field should contain "#AAAAAA"
    And the "Title link color" field should contain "#888888"
    And the "Visited title link color" field should contain "#0000f0"
    And the "Description text color" field should contain "#DDDDDD"
    And the "URL link color" field should contain "#007000"

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    And I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should see the page with internal CSS ".header-footer .staged h1\{color:green\}"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"

    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Font family" field should contain "Helvetica, sans-serif"
    And the "Left tab text color" field should contain "#AAAAAA"
    And the "Title link color" field should contain "#888888"
    And the "Visited title link color" field should contain "#0000f0"
    And the "Description text color" field should contain "#DDDDDD"
    And the "URL link color" field should contain "#007000"

  Scenario: Updating theme and saving it for preview
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #008000        | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | true          |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I choose "Virgin Islands"
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Staged changes to your site successfully"
    When I follow "Look and feel"
    Then the "Virgin Islands" theme should be selected

  Scenario: Editing look and feel and saving it for preview on a site with legacy template
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                       | {SiteName} : {Query}              |
      | Favicon URL                                                     | cdn.agency.gov/staged_favicon.ico |
      | External CSS URL                                                | cdn.agency.gov/staged_custom.css  |
      | Enter HTML to customize the top of your search results page.    | New header                        |
      | Enter HTML to customize the bottom of your search results page. | New footer                        |
    And I choose "Basic Gray"
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Staged changes to your site successfully"

    When I follow "View Current"
    Then I should see "gov - aff site Search Results"
    And I should see "Old header"
    And I should see "Old footer"
    And I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "default"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"
    And I should not see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    And I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"

  Scenario: Editing look and feel with problem and saving it for preview
    Given the following Affiliates exist:
      | display_name | name    | domains     | contact_email | contact_name | uses_one_serp |
      | aff site     | aff.gov | example.org | aff@bar.gov   | John Bar     | true          |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title |                       |
      | Title link color          | invalid color         |
      | Visited title link color  | invalid visited color |
    And I press "Save for Preview"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see "Search results page title can't be blank"
    And I should see "Title link color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits"

  Scenario: Editing look and feel and make it live on a site with one serp
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #008000        | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | true          |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And no emails have been sent
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                              | {SiteName} : {Query}              |
      | Favicon URL                                                            | cdn.agency.gov/staged_favicon.ico |
      | Left tab text color                                                    | #AAAAAA                           |
      | Title link color                                                       | #888888                           |
      | Visited title link color                                               | #0000f0                           |
      | Description text color                                                 | #DDDDDD                           |
      | URL link color                                                         | #007000                           |
      | Enter CSS to customize the top and bottom of your search results page. | .staged h1 { color: green; }      |
      | External CSS URL                                                       | cdn.agency.gov/staged_custom.css  |
      | Enter HTML to customize the top of your search results page.           | New header                        |
      | Enter HTML to customize the bottom of your search results page.        | New footer                        |
    And I select "Helvetica, sans-serif" from "Font family"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Updated changes to your live site successfully"
    And I should not see "View Staged"
    When "aff@bar.gov" opens the email
    And I should see "The header and/or footer for aff site have been updated" in the email body
    And I should see "Old header" in the email body
    And I should see "Old footer" in the email body
    And I should see "New header" in the email body
    And I should see "New footer" in the email body

    When I follow "View Current"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with internal CSS ".header-footer .staged h1\{color:green\}"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"

    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Font family" field should contain "Helvetica, sans-serif"
    And the "Left tab text color" field should contain "#AAAAAA"
    And the "Title link color" field should contain "#888888"
    And the "Visited title link color" field should contain "#0000f0"
    And the "Description text color" field should contain "#DDDDDD"
    And the "URL link color" field should contain "#007000"

  Scenario: Updating theme and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp | theme   | staged_theme |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #008000        | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | true          | natural | gray         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    Then the "Grand Canyon" theme should be selected
    When I choose "Virgin Islands"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Updated changes to your live site successfully"
    When I follow "Look and feel"
    Then the "Virgin Islands" theme should be selected

   Scenario: Editing look and feel and make it live on a site with legacy template and existing header/footer
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And no emails have been sent
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                              | {SiteName} : {Query}              |
      | Favicon URL                                                            | cdn.agency.gov/staged_favicon.ico |
      | Enter CSS to customize the top and bottom of your search results page. | .staged h1 { color: green; }      |
      | External CSS URL                                                       | cdn.agency.gov/staged_custom.css  |
      | Enter HTML to customize the top of your search results page.           | <b>New header</b>                 |
      | Enter HTML to customize the bottom of your search results page.        | New footer                        |
    And I choose "Basic Gray"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Updated changes to your live site successfully"
    And I should not see "View Staged"
    When "aff@bar.gov" opens the email
    And I should see "The header and/or footer for aff site have been updated" in the email body
    And I should see "Old header" in the email body
    And I should see "Old footer" in the email body
    And I should see "<b>New header</b>" in the email body
    And I should see "New footer" in the email body

    When I follow "View Current"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should see the page with internal CSS ".header-footer .staged h1\{color:green\}"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"

    Scenario: Editing look and feel and make it live on a site with legacy template without existing header/footer
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | favicon_url                       | external_css_url                 | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header    | Old footer    | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And no emails have been sent
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                       | {SiteName} : {Query}              |
      | Favicon URL                                                     | cdn.agency.gov/staged_favicon.ico |
      | External CSS URL                                                | cdn.agency.gov/staged_custom.css  |
      | Enter HTML to customize the top of your search results page.    | New header                        |
      | Enter HTML to customize the bottom of your search results page. | <b>New footer</b>                 |
    And I choose "Basic Gray"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Updated changes to your live site successfully"
    And I should not see "View Staged"
    When "aff@bar.gov" opens the email
    And I should see "The header and/or footer for aff site have been updated" in the email body
    And I should see "<b>New footer</b>" in the email body

    When I follow "View Current"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"

  Scenario: Editing look and feel with problem and make it live
    Given the following Affiliates exist:
      | display_name     | name            | domains       | contact_email         | contact_name        | uses_one_serp |
      | aff site         | aff.gov         | example.org   | aff@bar.gov           | John Bar            | true          |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title |                       |
      | Left tab text color       | invalid color         |
      | Title link color          | invalid color         |
      | Visited title link color  | invalid visited color |
      | Description text color    | invalid color         |
      | URL link color            | invalid color         |
    And I press "Make Live"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see "Search results page title can't be blank"
    And I should see "Left tab text color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Title link color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Description text color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Url link color should consist of a # character followed by 3 or 6 hexadecimal digits"

  Scenario: Editing look and feel where staged and live sites are out of sync and has_staged_content is false
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | affiliate_template_name | search_results_page_title | domains  | header_footer_css            | header      | footer      | favicon_url                | external_css_url          | staged_affiliate_template_name | staged_search_results_page_title | staged_header_footer_css     | staged_header | staged_footer | staged_favicon_url                | staged_external_css_url          | has_staged_content | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | Default                 | Live Search Results       | data.gov | .current h1 { color: blue; } | Live header | Live footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | Basic Gray                     | Staged Search Results            | .staged h1 { color: green; } | Staged header | Staged footer | cdn.agency.gov/staged_favicon.ico | cdn.agency.gov/staged_custom.css | false              | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Search results page title" field should contain "Live Search Results"
    And the "Default" template should be selected
    And the "Favicon URL" field should contain "http://cdn.agency.gov/favicon.ico"
    And the "Enter CSS to customize the top and bottom of your search results page." field should contain "\.current h1 \{ color: blue; \}"
    And the "External CSS URL" field should contain "http://cdn.agency.gov/custom.css"
    And the "Enter HTML to customize the top of your search results page." field should contain "Live header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "Live footer"
    When I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Staged changes to your site successfully"
    When I follow "View Staged"
    Then I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "default"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should see "Live Search Results"
    And I should see 10 search results
    And I should see "Live header"
    And I should see "Live footer"

  Scenario: Editing look and feel where staged and live sites are out sync and has_staged_content is true
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | affiliate_template_name | search_results_page_title | domains  | header_footer_css            | header      | footer      | favicon_url                | external_css_url          | staged_affiliate_template_name | staged_search_results_page_title | staged_header_footer_css     | staged_header | staged_footer | staged_favicon_url                | staged_external_css_url          | has_staged_content | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | Default                 | Live Search Results       | data.gov | .current h1 { color: blue; } | Live header | Live footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | Basic Gray                     | Staged Search Results            | .staged h1 { color: green; } | Staged header | Staged footer | cdn.agency.gov/staged_favicon.ico | cdn.agency.gov/staged_custom.css | true               | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Search results page title" field should contain "Staged Search Results"
    And the "Basic Gray" template should be selected
    And the "Favicon URL" field should contain "http://cdn.agency.gov/staged_favicon.ico"
    And the "Enter CSS to customize the top and bottom of your search results page." field should contain "\.staged h1 \{ color: green; \}"
    And the "External CSS URL" field should contain "http://cdn.agency.gov/staged_custom.css"
    And the "Enter HTML to customize the top of your search results page." field should contain "Staged header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "Staged footer"
    When I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Staged changes to your site successfully"
    When I follow "View Staged"
    Then I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should not see the page with affiliate stylesheet "default"
    And I should see "Staged Search Results"
    And I should see "Staged header"
    And I should see "Staged footer"

  Scenario: Resetting style on a site with one serp
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #007000        | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | true          |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    Then the "Left tab text color" field should contain "#BBBBBB"
    And the "Title link color" field should contain "#33ff33"
    And the "Visited title link color" field should contain "#0000ff"
    And the "Description text color" field should contain "#CCCCCC"
    And the "URL link color" field should contain "#007000"
    When I fill in the following:
      | Left tab text color      |  |
      | Title link color         |  |
      | Visited title link color |  |
      | Description text color   |  |
      | URL link color           |  |
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Staged changes to your site successfully"

    When I follow "Look and feel"
    Then the "Left tab text color" field should contain "#9E3030"
    And the "Title link color" field should contain "#2200CC"
    And the "Visited title link color" field should contain "#800080"
    And the "Description text color" field should contain "#000000"
    And the "URL link color" field should contain "#008000"
    
  Scenario: Visiting an affiliate SERP without a header
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains        |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | whitehouse.gov |
    When I go to aff.gov's search page
    Then show me the page
    Then I should see "aff site" as a header
    
    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | search_results_page_title           | domains        | header  |
      | aff2 site     | aff2.gov  | aff2@bar.gov    | John Bar     | {Query} - {SiteName} Search Results | whitehouse.gov |         |
    When I go to aff2.gov's search page
    Then I should see "aff2 site" as a header
    
  Scenario: Enabling/Disabling popular urls
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains        | header     | footer     | staged_header | staged_footer | is_popular_links_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | whitehouse.gov | Old header | Old footer | Old header    | Old footer    | true                     |
    And the following popular URLs exist:
      | affiliate_name  | title         | url                 | rank  |
      | aff.gov         | popurl title  | http://popurl.gov/  | 1     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to aff.gov's search page
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should see "Popular Links"

    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Popular Links"
    And I uncheck "Enable Popular Links?"
    And I press "Set Preferences"
    Then I should see "Popular Links DISABLED"

    When I go to aff.gov's search page
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should not see "Popular Links"

    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Popular Links"
    And I check "Enable Popular Links?"
    And I press "Set Preferences"
    Then I should see "Popular Links ENABLED"

  Scenario: Cancelling staged changes from the Affiliate Center page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | affiliate_template_name | search_results_page_title | domains  | header      | footer      | favicon_url                | external_css_url          | staged_affiliate_template_name | staged_search_results_page_title | staged_header | staged_footer | staged_favicon_url                | staged_external_css_url          | has_staged_content | uses_one_serp |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | Default                 | Live Search Results       | data.gov | Live header | Live footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | Basic Gray                     | Staged Search Results            | Staged header | Staged footer | cdn.agency.gov/staged_favicon.ico | cdn.agency.gov/staged_custom.css | true               | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I press "Cancel Changes"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > bar site
    And I should see "Staged changes were successfully cancelled."
    And I should not see "View Staged"
    And I should not see "Push Changes" button
    And I should not see "Cancel Changes" button
    When I follow "View Current"
    Then I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "default"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"
    And I should see "Live header"
    And I should see "Live footer"

  Scenario: Cancelling staged changes from the site specific Affiliate Center page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains  | header     | footer     | favicon_url                       | external_css_url                 | uses_one_serp |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | data.gov | Old header | Old footer | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "bar site" affiliate page
    And I follow "Look and feel"
    And I fill in the following:
      | Favicon URL                                                     | cdn.agency.gov/staged_favicon.ico |
      | External CSS URL                                                | cdn.agency.gov/staged_custom.css  |
      | Search results page title                                       | updated SERP title                |
      | Enter HTML to customize the top of your search results page.    | New header                        |
      | Enter HTML to customize the bottom of your search results page. | New footer                        |
    And I choose "Basic Gray"
    And I press "Save for Preview"
    And I should see "Staged changes to your site successfully"
    Then I should see "Cancel Changes" button
    When I follow "View Staged"
    Then I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should see "updated SERP title"
    And I should see "New header"
    And I should see "New footer"

    When I go to the "bar site" affiliate page
    And I press "Cancel Changes"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > bar site
    And I should see "Staged changes were successfully cancelled."
    And I should not see "View Staged"
    And I should not see "Push Changes" button
    And I should not see "Cancel Changes" button
    When I follow "View Current"
    Then I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "default"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"
    And I should see "gov - bar site Search Results"
    And I should see "Old header"
    And I should see "Old footer"
    And I should see 10 search results

  Scenario: Cancelling staged changes from the Preview page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | affiliate_template_name | search_results_page_title | domains  | header      | footer      | favicon_url                | external_css_url          | staged_affiliate_template_name | staged_search_results_page_title | staged_header | staged_footer | staged_favicon_url                | staged_external_css_url          | has_staged_content | uses_one_serp |
      | aff site     | bar.gov | aff@bar.gov   | John Bar     | Default                 | Live Search Results       | data.gov | Live header | Live footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | Basic Gray                     | Staged Search Results            | Staged header | Staged footer | cdn.agency.gov/staged_favicon.ico | cdn.agency.gov/staged_custom.css | true               | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Preview"
    And I press "Cancel Staged Changes"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
    And I should see "Staged changes were successfully cancelled."
    And I should not see "View Staged"
    And I should not see "Push Changes" button
    And I should not see "Cancel Changes" button
    When I follow "View Current"
    Then I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "default"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"
    And I should see "Live Search Results"
    And I should see "Live header"
    And I should see "Live footer"

  Scenario: Visiting the preview page
    Given the following Affiliates exist:
      | display_name    | name           | contact_email | contact_name | is_sayt_enabled |
      | aff site        | aff.gov        | aff@aff.gov   | John Bar     | true            |
      | nosayt aff site | nosayt.aff.gov | aff@aff.gov   | John Bar     | false           |
    And I am logged in with email "aff@aff.gov" and password "random_string"
    When I go to the "nosayt aff site" affiliate page
    And I follow "Preview"
    Then affiliate SAYT suggestions for "aff.gov" should be disabled

    When I go to the "aff site" affiliate page
    And I follow "Preview"
    Then I should see "Preview" within "title"
    And affiliate SAYT suggestions for "aff.gov" should be enabled
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
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site
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
    And the following SAYT Suggestions exist for aff.gov:
    | phrase                 |
    | Some Unique Obama Term |
    | el paso term           |
    When I go to aff.gov's search page
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should see "Related Searches" in the search results section
    And I should see "some unique obama term"
    And I should not see "aff.gov"

  Scenario: Affiliate SAYT
    Given the following Affiliates exist:
      | display_name | name         | contact_email    | contact_name   | domains | is_sayt_enabled |
      | aff site     | aff.gov      | aff@bar.gov      | John Bar       | usa.gov | true            |
      | other site   | otheraff.gov | otheraff@bar.gov | Other John Bar | usa.gov | false           |
    When I go to aff.gov's search page
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "aff.gov" should be enabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "aff.gov" should be enabled

    When I go to otheraff.gov's search page
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "otheraff.gov" should be disabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "otheraff.gov" should be disabled

  Scenario: Visiting Affiliate SAYT demo page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains | is_sayt_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | usa.gov | false           |
    When I go to the affiliate sayt demo page for aff.gov
    Then the affiliate search bar should have SAYT enabled
    And affiliate SAYT suggestions for "aff.gov" should be enabled

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
    And I should see "The following is the HTML code for your search page. Copy and paste this code into your page(s) where the search box should appear."
    And I should see the code for English language sites
    And I should see "Code for content discovery and indexing"
    And I should see the stats code

  Scenario: Getting an embed code for my affiliate site search in Spanish
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | locale  |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            | es      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Get code"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Get Code
    And I should see "The following is the HTML code for your search page. Copy and paste this code into your page(s) where the search box should appear."
    And I should see the code for Spanish language sites
    And I should see "Code for content discovery and indexing"
    And I should see the stats code

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

  Scenario: Setting SAYT Preferences for an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | is_sayt_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead search"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Type-ahead Search
    And I should see "Type-ahead Search" in the page header
    And I should see "Preferences"
    And the "is_sayt_enabled" checkbox should be checked

    When I uncheck "is_sayt_enabled"
    And I press "Set Preferences"
    Then I should see "Preferences updated"
    And I should see "Type-ahead Search" in the page header
    And the "is_sayt_enabled" checkbox should not be checked

  Scenario: Adding and removing a SAYT Suggestion to an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | is_sayt_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true            |
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

  Scenario: Deleting all SAYT suggestions
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | is_sayt_enabled |
      | agency       | aff.gov | aff@bar.gov   | John Bar     | true            |
    And the following SAYT Suggestions exist for aff.gov:
      | phrase     |
      | education  |
      | healthcare |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead search"
    And I should see 2 type-ahead search suggestions
    When I press "Delete all"
    Then I should see "All type-ahead search suggestions successfully deleted."
    And I should see "Site agency has no type-ahead search suggestions"
    And I should not see any type-ahead search suggestion

  Scenario: Adding a misspelled SAYT Suggestion to an affiliate
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | is_sayt_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true            |
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
      | display_name | name    | contact_email | contact_name | is_sayt_enabled |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true            |
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
      | display_name | name      | contact_email | contact_name | affiliate_template_name |
      | aff site     | aff.gov   | aff@bar.gov   | John Bar     | Default                 |
      | another site | other.gov | aff@other.gov | Jane Doe     | Default                 |
    And the following popular URLs exist:
      | affiliate_name | title                                                                                                 | url                       | rank |
      | aff.gov        | Space, NASA Information & News, Outer Space Flight Videos & Pictures - Astronomy, Solar System Images | http://awesome.gov/blog/7 | 7    |
      | aff.gov        | Awesome sixth blog post                                                                               | http://awesome.gov/blog/6 | 6    |
      | aff.gov        | Awesome fourth blog post                                                                              | http://awesome.gov/blog/4 | 4    |
      | aff.gov        | Awesome fifth blog post                                                                               | http://awesome.gov/blog/5 | 5    |
      | aff.gov        | Awesome third blog post                                                                               | http://awesome.gov/blog/3 | 3    |
      | aff.gov        | Awesome second blog post                                                                              | http://awesome.gov/blog/2 | 2    |
    When I go to aff.gov's search page
    Then I should see 3 popular URLs
    And I should see a link to "Space, NASA Information & News, Outer Space Flight Videos & Pictures -..." with url for "http://awesome.gov/blog/7" in the popular urls section
    And I should see a link to "Awesome sixth blog post" with url for "http://awesome.gov/blog/6" in the popular urls section
    And I should see a link to "Awesome fifth blog post" with url for "http://awesome.gov/blog/5" in the popular urls section
    And I should not see a link to "Awesome fourth blog post"
    And I should not see a link to "Awesome second blog post"
    And I should not see a link to "Awesome third blog post"

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

  Scenario: Site visitor sees both boosted result and featured collection for a given search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | exclude_webtrends |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true              |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title              | url                    | description                          |
      | Our Emergency Page | http://www.aff.gov/911 | Updated information on the emergency |
      | FAQ Emergency Page | http://www.aff.gov/faq | More information on the emergency    |
    Given the following featured collections exist for the affiliate "aff.gov":
      | title                    | locale | status |
      | Emergency & Safety Pages | en     | active |
    And the following featured collection links exist for featured collection titled "Emergency & Safety Pages":
      | title          | url                               |
      | Emergency Info | http://www.agency.org/emergency/1 |
      | Safety Info    | http://www.agency.org/safety/1    |
    And I am on aff.gov's search page
    And I fill in "query" with "emergency"
    And I press "Search"
    Then I should see "Our Emergency Page" in the boosted contents section
    And I should see "FAQ Emergency Page" in the boosted contents section
    And I should see "Emergency & Safety Pages" in the featured collections section

  Scenario: Visiting Best Bets index page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Best Bets

    When I follow "Text"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Best Bets: Text

    When I follow "Best bets"
    And I follow "Graphics"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Best Bets: Graphics

    When I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Best Bets: Text

    When I follow "Best bets"
    And I follow "Add new text" in the affiliate boosted contents section
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Add a new Best Bets: Text

    When I follow "Best bets"
    And I follow "Bulk upload" in the affiliate boosted contents section
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Bulk Upload Best Bets: Text

    When I follow "Best bets"
    And I follow "View all" in the featured collections section
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Best Bets: Graphics

    When I follow "Best bets"
    And I follow "Add new graphics" in the featured collections section
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Add a new Best Bets: Graphics

  Scenario: Excluding a URL from affiliate SERPs
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains         |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | whitehouse.gov  |
    And the following RSS feeds exist:
    | affiliate | url                                             | name    |
    | aff.gov   | http://www.whitehouse.gov/feed/blog/white-house | WH Blog |
    And the following News Items exist:
    | link                                      | title                              | guid  | description         | feed_name |
    | http://www.whitehouse.gov/our-government  |  Our Government \| The White House | 12345 | white house cabinet | WH Blog   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Site information"
    And I follow "Emergency Delete"
    And I fill in "URL*" with "http://www.whitehouse.gov/our-government"
    And I press "Add"
    And I fill in "URL*" with "http://www.whitehouse.gov/fake-page"
    And I press "Add"

    When I go to aff.gov's search page
    And I fill in "query" with "white house cabinet"
    And I press "Search"
    Then I should see some Bing search results

    When I follow "WH Blog"
    Then I should see "Sorry, no results found for 'white house cabinet'"

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Site information"
    And I follow "Emergency Delete"
    And I press "Delete"
    And I press "Delete"

    When I go to aff.gov's search page
    And I fill in "query" with "white house cabinet"
    And I press "Search"
    Then I should see some Bing search results

    When I follow "WH Blog"
    Then I should see "Results 1-1 of about 1 for 'white house cabinet'"
    And I should see "white house cabinet"

  Scenario: Inputing a bad Excluded Url
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains         |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | whitehouse.gov  |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Site information"
    And I follow "Emergency Delete"
    And I fill in "URL*" with "www.whitehouse.gov/our-government"
    And I press "Add"
    Then I should see "Url is invalid"

  Scenario: Visiting the social media page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | facebook_handle | flickr_url                           | twitter_handle | youtube_handle |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | FBAgency        | http://www.flickr.com/groups/usagov/ | TwitterAgency  | YouTubeAgency  |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Social Media"
    Then I should see the browser page titled "Social Media"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > Social Media
    And I should see "Social Media" in the page header
    And the "Facebook handle" field should contain "FBAgency"
    And the "Flickr URL" field should contain "http://www.flickr.com/groups/usagov/"
    And the "Twitter handle" field should contain "TwitterAgency"
    And the "YouTube handle" field should contain "YouTubeAgency"
    When I fill in the following:
      | Facebook handle | UpdatedFBAgency                             |
      | Flickr URL      | http://www.flickr.com/groups/updatedusagov/ |
      | Twitter handle  | UpdatedTwitterAgency                        |
      | YouTube handle  | UpdatedYouTubeAgency                        |
    And I press "Save"
    Then I should see "Site was successfully updated."
    When I follow "Social Media"
    Then the "Facebook handle" field should contain "UpdatedFBAgency"
    And the "Flickr URL" field should contain "http://www.flickr.com/groups/updatedusagov/"
    And the "Twitter handle" field should contain "UpdatedTwitterAgency"
    And the "YouTube handle" field should contain "UpdatedYouTubeAgency"
    When I follow "Cancel"
    Then I should see the browser page titled "Site: aff site"

  Scenario: Visiting the URLs & Sitemaps page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "URLs & Sitemaps"
    Then I should see the browser page titled "URLs & Sitemaps"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > aff site > URLs & Sitemaps
    And I should see "URLs & Sitemaps for USASearch Index" in the page header
    And I should see a link to "sitemaps.org/protocol.html" with url for "http://www.sitemaps.org/protocol.html"
    And I should see "Sitemaps (0)"
    And I should see "Site aff site has no sitemaps"
    And I should see "Uncrawled URLs (0)"
    And I should see "Crawled URLs (0)"

    When there are 8 uncrawled IndexedDocuments for "aff.gov"
    And there are 10 crawled IndexedDocuments for "aff.gov"
    And I go to the "aff site" affiliate page
    And I follow "URLs & Sitemaps"
    Then I should see "Uncrawled URLs (8)"
    And I should see "Crawled URLs (10)"
