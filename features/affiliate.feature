Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    When I go to the affiliate welcome page
    Then I should see "Sign In to Use Our Services"

  Scenario: Visiting the admin center page as super admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I should see an image link to "USASearch" with url for "http://usasearch.howto.gov" in the logo
    And I should see a link to "USASearch" with url for "http://usasearch.howto.gov" in the breadcrumbs
    And I should see a link to "Super Admin" in the main navigation bar
    And I should not see a link to "Analytics Center" in the main navigation bar
    And I should not see a link to "Admin Center" in the main navigation bar

  Scenario: Visiting the admin center page as affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    Then I should see a link to "Home" with url for "http://usasearch.howto.gov" in the main navigation bar
    And I should see a link to "About Us" with url for "http://usasearch.howto.gov/about-us" in the main navigation bar
    And I should see a link to "Features" with url for "http://usasearch.howto.gov/features" in the main navigation bar
    And I should see a link to "Success Stories" with url for "http://usasearch.howto.gov/customers" in the main navigation bar
    And I should see a link to "HelpDesk" with url for "http://usasearch.howto.gov/help-desk" in the main navigation bar
    And I should see a link to "Admin Center" in the main navigation bar
    And I should not see a link to "Super Admin" in the main navigation bar
    And I should not see a link to "Analytics Center" in the main navigation bar
    And I should see a link to "USASearch" with url for "http://usasearch.howto.gov" in the breadcrumbs
    And I should see a link to "About Us" with url for "http://usasearch.howto.gov/about-us" in the footer
    And I should see a link to "Terms of Service" with url for "http://usasearch.howto.gov/tos" in the footer
    And I should see a link to "Follow Us on Twitter" with url for "http://www.twitter.com/usasearch" in the footer
    And I should see a link to "USASearch@gsa.gov" with url for "mailto:***REMOVED***" in the footer
    And I should see a link to "Office of Citizen Services & Innovative Technologies" with url for "http://www.gsa.gov/portal/category/25729" in the footer

  Scenario: Visiting the Affiliate API Pages as affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the affiliate admin page with "usagov" selected
    And I follow "Search API"
    Then I should see the browser page titled "Search API"
    And I should see the following breadcrumbs: USASearch > Admin Center > USA.gov > Search API
    And I should see "Search API" in the page header
    And I should see the API key
    And I should see a link to "Terms of Service" with url for "http://usasearch.howto.gov/tos" in the API key box
    And I should see a link to "Terms of Service" with url for "http://usasearch.howto.gov/tos" in the API TOS section

  Scenario: Visiting the affiliate admin page as affiliate with existing sites
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    Then I should see the browser page titled "Admin Center"
    And I should see the following breadcrumbs: USASearch > Admin Center
    And I should see "Admin Center" in the page header
    And I should see "Site List"
    And I should see "add new site"

    When I follow "Admin Center" in the main navigation bar
    Then I should see the browser page titled "Admin Center"

  Scenario: Visiting the affiliate admin page as affiliate without existing sites
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    Then I should see the browser page titled "Admin Center"
    And I should see the following breadcrumbs: USASearch > Admin Center
    And I should see "Admin Center" in the page header
    And I should see "You currently have no sites."
    When I follow "Add New Site"
    Then I should see the browser page titled "Add a New Site"

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
    When I follow "Admin Center"
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
    Then I should see the browser page titled "Add a New Site"
    And I should see the following breadcrumbs: USASearch > Admin Center > Add New Site
    And I should see "Add a New Site" in the page header
    And I should see "Step 1. Basic Settings" in the site wizards header
    And I should see "Basic Settings"
    When I fill in the following:
      | Site name (Required)                          | My awesome agency |
      | Site Handle (visible to searchers in the URL) | agencygov         |
    And I choose "Gettysburg"
    And I press "Next"
    Then I should see the browser page titled "Add a New Site"
    And I should see the following breadcrumbs: USASearch > Admin Center > Add New Site
    And I should see "Add a New Site" in the page header
    And I should see "Step 2. Set up site" in the site wizards header
    And I should see "Content Sources"
    When I fill in the following:
      | Enter the domain or URL | agency.gov                                                                   |
      | Sitemap URL             | http://search.usa.gov/usasearch_hosted_sitemap/485.xml                       |
      | RSS Feed URL            | http://www.fda.gov/AboutFDA/ContactFDA/StayInformed/RSSFeeds/Recalls/rss.xml |
      | RSS Feed Name           | Recalls Feed                                                                 |
    And I press "Next"
    Then I should see the browser page titled "Add a New Site"
    And I should see the following breadcrumbs: USASearch > Admin Center > Add New Site
    And I should see "Add a New Site" in the page header
    And I should see "Step 3. Get the code" in the site wizards header
    And I should see the code for English language sites
    When I go to the "My awesome agency" affiliate page
    And I follow "Site information"
    Then the "Site name" field should contain "My awesome agency"

    When I follow "Look and feel"
    Then the "Gettysburg" theme should be selected
    And the "Page background color" field should contain "#F7F7F7"
    And the "Content background color" field should contain "#FFFFFF"
    And the "Add top padding" checkbox should not be checked
    And the "Content border color" field should contain "#CACACA"
    And the "Content border color" field should be disabled
    And the "Add drop shadow" checkbox should be checked
    And the "Content box shadow color" field should contain "#555555"
    And the "Content box shadow color" field should be disabled
    And the "Search button text color" field should contain "#FFFFFF"
    And the "Search button background color" field should contain "#336699"
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

    When I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    And the "Header text" field should contain "My awesome agency"
    And the "Header text color" field should contain "#FFFFFF"
    And the "Header background color" field should contain "#336699"
    And the "Header/footer link color" field should contain "#336699"
    And the "Header/footer link background color" field should contain "#FFFFFF"

    When I follow "Domains"
    Then I should see the following table rows:
      | Label       | Domain         |
      | agency.gov  | agency.gov     |

    When I follow "Sidebar"
    Then the "Default search label" field should contain "Everything"
    And the "Image search label" field should contain "Images"
    And the "Is image search enabled" checkbox should be checked
    And the "RSS feed 0" field should contain "Recalls Feed"
    And the "Is RSS feed 0 navigable" checkbox should not be checked
    And the "Show by time period module" checkbox should be checked

    When I follow "Results modules"
    Then the "Is agency govbox enabled" checkbox should not be checked
    And the "Is medline govbox enabled" checkbox should not be checked
    And I should see the following table rows:
      | Name         | Source    |
      | Agency       | USASearch |
      | Medline      | USASearch |
      | Recalls Feed | RSS       |
    And the "Show RSS feed 0 in govbox" checkbox should not be checked
    And the "Is related searches enabled" checkbox should be checked
    And the "Show deep links" checkbox should be checked

    When I go to agencygov's search page
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see "My awesome agency" in the SERP header
    And I should see "Images" in the left column
    And I should not see "Recalls Feed" in the left column

  Scenario: Adding a new Spanish affiliate
    Given I am logged in with email "affiliate_with_no_contact_info@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    When I fill in the following:
      | Site name (Required)                          | My awesome agency |
      | Site Handle (visible to searchers in the URL) | agencygov         |
    And I choose "Spanish"
    And I press "Next"
    And I press "Next"
    Then I should see the code for Spanish language sites
    When I go to agencygov's search page
    And I fill in "query" with "White House"
    And I press "Buscar"
    Then I should see "White House - My awesome agency Search Results"
    And I should see "Búsqueda avanzada"
    When I go to the "My awesome agency" affiliate page
    And I follow "Site information"
    Then the "Spanish" checkbox should be checked

  Scenario: Affiliates receive confirmation email when creating a new affiliate
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I fill in the following:
      | Site name (Required)                          | My awesome agency |
      | Site Handle (visible to searchers in the URL) | agencygov         |
    And I press "Next"
    And I press "Next"
    Then "affiliate_manager_with_no_affiliates@fixtures.org" should receive an email
    When I open the email
    Then I should see "Your new Affiliate site" in the email subject
    And I should see "Dear A New Manager" in the email body
    And I should see "Site name: My awesome agency" in the email body
    And I should see "affiliate_manager_with_no_affiliates@fixtures.org" in the email body

  Scenario: Adding an affiliate without valid site information should fail
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Site"
    And I press "Next"
    Then I should see "Site name can't be blank"
    And I should not see "Site Handle (visible to searchers in the URL) can't be blank"
    And I should not see "Site Handle (visible to searchers in the URL) is too short"
    And I should not see "Site Handle (visible to searchers in the URL) is invalid"
    When I fill in the following:
      | Site name (Required)                          | My awesome agency |
      | Site Handle (visible to searchers in the URL) | agencygov         |
    And I press "Next"
    And I fill in "Enter the domain or URL" with "notavaliddomain"
    And I press "Next"
    Then I should see "Domain is invalid"

    When I fill in the following:
      | Enter the domain or URL | www1.mydomain.gov |
    And I press "Next"
    And I should see "Get the code"

  Scenario: Adding a new site as an affiliate user with pending_contact_information status
    Given I am on the login page
    When I fill in the following in the new user form:
    | Email                         | lorem.ipsum@corporate.com   |
    | Name                          | Lorem Ipsum                 |
    | Password                      | huge_secret                 |
    | Password confirmation         | huge_secret                 |
    And I check "I am a government employee or contractor"
    And I check "I have read and accept the"
    And I press "Register for a new account"
    Then I should be on the affiliate admin page
    And I should see a link to "Admin Center" in the main navigation bar
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

  Scenario: Visiting the site specific Admin Center
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
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Site Information
    And I should see "Site Information" within ".main"
    And the "Site name" field should contain "aff site"
    And the "Site Handle (visible to searchers in the URL)" field should contain "aff.gov"
    And I should see "Cancel"
    When I follow "Cancel"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site

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
    Then I should see the following breadcrumbs: USASearch > Admin Center > new aff site
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

  Scenario: Visiting the look and feel page on a site with legacy template
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | header     | footer     | favicon_url                | external_css_url          | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then I should see the browser page titled "Look and Feel"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Look and Feel of the Search Results Page
    And I should see "Look and Feel" in the page header
    And the "Continue using legacy template" radio button should be checked
    And the "Search results page title" field should contain "\{Query\} - \{SiteName\} Search Results"
    And the "Default" template should be selected
    And the "Favicon URL" field should contain "cdn.agency.gov/favicon.ico"
    When I follow "Cancel"
    Then I should see the browser page titled "Site: aff site"

  Scenario: Updating the look and feel from legacy template to one serp and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | header     | footer     | favicon_url                | external_css_url          | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Font family" field should contain "Arial, sans-serif"
    And the "Add top padding" checkbox should not be checked
    And the "Add drop shadow" checkbox should not be checked
    And the "Liberty Bell" theme should be selected

    When I choose "Start using One SERP theme"
    And I choose "Virgin Islands"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"

    When I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see "Old header"
    And I should see "Old footer"

    When I go to the "aff site" affiliate page
    When I follow "Look and feel"
    Then the "Virgin Islands" theme should be selected
    And I should not see "Start using One SERP theme"
    And I should not see "Template"

    When I follow "Header and footer"
    Then I should see "Use a managed header/footer"

  Scenario: Updating the look and feel from legacy template to one serp and save it for preview
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | header     | footer     | favicon_url                | external_css_url          | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    And I choose "Start using One SERP theme"
    And I select "Times, serif" from "Font family"
    And I check "Add top padding"
    And I check "Add drop shadow"
    And I choose "Virgin Islands"
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"

    When I follow "View Current"
    Then I should not see the page with affiliate stylesheet "one_serp"
    And I should see "Old header"
    And I should see "Old footer"

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 2. Use CSS/HTML code to create a custom header/footer" radio button should be checked
    When I choose "Option 1. Use a managed header/footer"
    And I fill in the following:
      | Header text     | updated header text without image |
      | Header home URL | www.agency.gov                    |
    And I press "Save for Preview"
    Then I should see "Staged changes to your site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with content border
    And I should see the page with content box shadow
    And I should see a link to "updated header text without image" with url for "http://www.agency.gov"

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    Then I should see "Staged content is now visible"
    When I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with content border
    And I should see the page with content box shadow
    And I should see a link to "updated header text without image" with url for "http://www.agency.gov"

  Scenario: Editing user interface and saving it for preview on a site with one serp
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | page_background_color | content_background_color | search_button_text_color | search_button_background_color | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | header_footer_css         | header     | footer     | favicon_url                | external_css_url          | uses_one_serp | theme  | show_content_border | show_content_box_shadow | uses_managed_header_footer |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #FFFFFF               | #F2F2F2                  | #111111                  | #0000EE                        | #BBBBBB             | #33FF33          | #0000FF                  | #CCCCCC                | #009000        | .current { color: blue; } | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | true          | custom | false               | false                   | false                      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    Then I should see the browser page titled "Look and Feel"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Look and Feel of the Search Results Page
    And I should see "Look and Feel" in the page header
    And I should not see "Start using One SERP theme"
    And the "Search results page title" field should contain "\{Query\} - \{SiteName\} Search Results"
    And the "Favicon URL" field should contain "cdn.agency.gov/favicon.ico"
    And I should not see "Template"
    And the "Font family" field should contain "Verdana, sans-serif"
    And the "Custom" theme should be selected
    And the "Custom" theme should be visible
    And the "Page background color" field should contain "#FFFFFF"
    And the "Content background color" field should contain "#F2F2F2"
    And the "Add top padding" checkbox should not be checked
    And the "Content border color" field should contain "#CACACA"
    And the "Add drop shadow" checkbox should not be checked
    And the "Content box shadow color" field should contain "#555555"
    And the "Search button text color" field should contain "#111111"
    And the "Search button background color" field should contain "#0000EE"
    And the "Left tab text color" field should contain "#BBBBBB"
    And the "Title link color" field should contain "#33FF33"
    And the "Visited title link color" field should contain "#0000FF"
    And the "Description text color" field should contain "#CCCCCC"
    And the "URL link color" field should contain "#009000"
    When I fill in the following:
      | Search results page title                                              | {SiteName} : {Query}              |
      | Favicon URL                                                            | cdn.agency.gov/staged_favicon.ico |
      | Page background color                                                  | #EEEEEE                           |
      | Content background color                                               | #D6D6D6                           |
      | Content border color                                                   | #D8D8D8                           |
      | Content box shadow color                                               | #777777                           |
      | Search button text color                                               | #222222                           |
      | Search button background color                                         | #00DD00                           |
      | Left tab text color                                                    | #AAAAAA                           |
      | Title link color                                                       | #888888                           |
      | Visited title link color                                               | #0000f0                           |
      | Description text color                                                 | #DDDDDD                           |
      | URL link color                                                         | #007000                           |
    And I select "Helvetica, sans-serif" from "Font family"
    And I check "Add top padding"
    And I check "Add drop shadow"
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"

    When I follow "Look and feel"
    Then the "Search results page title" field should contain "\{SiteName\} : \{Query\}"
    And the "Favicon URL" field should contain "http://cdn.agency.gov/staged_favicon.ico"
    Then the "Font family" field should contain "Helvetica, sans-serif"
    And the "Page background color" field should contain "#EEEEEE"
    And the "Content background color" field should contain "#D6D6D6"
    And the "Add top padding" checkbox should be checked
    And the "Content border color" field should contain "#D8D8D8"
    And the "Add drop shadow" checkbox should be checked
    And the "Content box shadow color" field should contain "#777777"
    And the "Search button text color" field should contain "#222222"
    And the "Search button background color" field should contain "#00DD00"
    And the "Left tab text color" field should contain "#AAAAAA"
    And the "Title link color" field should contain "#888888"
    And the "Visited title link color" field should contain "#0000f0"
    And the "Description text color" field should contain "#DDDDDD"
    And the "URL link color" field should contain "#007000"

    When I follow "Header and footer"
    Then I should see the browser page titled "Header and Footer of the Search Results Page"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Header and Footer of the Search Results Page
    And I should see "Header and Footer" in the page header
    Then the "External CSS URL" field should contain "http://cdn.agency.gov/custom.css"
    And the "Enter CSS to customize the top and bottom of your search results page." field should contain ".current \{ color: blue; \}"
    And the "Enter HTML to customize the top of your search results page." field should contain "Old header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "Old footer"
    When I fill in the following:
      | External CSS URL                                                       | cdn.agency.gov/staged_custom.css |
      | Enter CSS to customize the top and bottom of your search results page. | .staged { color: green; }        |
      | Enter HTML to customize the top of your search results page.           | New header                       |
      | Enter HTML to customize the bottom of your search results page.        | New footer                       |
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"

    When I follow "Header and footer"
    Then the "External CSS URL" field should contain "http://cdn.agency.gov/staged_custom.css"
    And the "Enter CSS to customize the top and bottom of your search results page." field should contain ".staged \{ color: green; \}"
    And the "Enter HTML to customize the top of your search results page." field should contain "New header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "New footer"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see "gov - aff site Search Results"
    And I should see "Old header"
    And I should see "Old footer"
    And I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with internal CSS ".header-footer .current\{color:blue\}"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"
    And I should not see the page with content border
    And I should not see the page with content box shadow
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
    And I should see the page with internal CSS ".header-footer .staged\{color:green\}"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should see the page with content border
    And I should see the page with content box shadow
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with external affiliate stylesheet "ht tp://cdn.agency.gov/custom.css"

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    Then I should see "Staged content is now visible"

    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Font family" field should contain "Helvetica, sans-serif"
    And the "Page background image repeat" field should contain "no-repeat"
    And the "Page background color" field should contain "#EEEEEE"
    And the "Content background color" field should contain "#D6D6D6"
    And the "Add top padding" checkbox should be checked
    And the "Content border color" field should contain "#D8D8D8"
    And the "Add drop shadow" checkbox should be checked
    And the "Content box shadow color" field should contain "#777777"
    And the "Search button text color" field should contain "#222222"
    And the "Search button background color" field should contain "#00DD00"
    And the "Left tab text color" field should contain "#AAAAAA"
    And the "Title link color" field should contain "#888888"
    And the "Visited title link color" field should contain "#0000f0"
    And the "Description text color" field should contain "#DDDDDD"
    And the "URL link color" field should contain "#007000"
    When I follow "Header and footer"
    Then the "External CSS URL" field should contain "http://cdn.agency.gov/staged_custom.css"
    And the "Enter CSS to customize the top and bottom of your search results page." field should contain ".staged \{ color: green; \}"
    And the "Enter HTML to customize the top of your search results page." field should contain "New header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "New footer"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see "aff site : gov"
    And I should see "New header"
    And I should see "New footer"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should see the page with internal CSS ".header-footer .staged\{color:green\}"
    And I should see the page with content border
    And I should see the page with content box shadow
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with external affiliate stylesheet "http://cdn.agency.gov/custom.css"

  Scenario: Updating theme and saving it for preview
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | search_button_text_color | search_button_background_color | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #111111                  | #0000EE                        | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #008000        | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | true          |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I choose "Virgin Islands"
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
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
    And I choose "Basic Gray"
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"

    When I follow "View Current"
    Then I should see "gov - aff site Search Results"
    And I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "default"
    And I should not see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should not see the page with affiliate stylesheet "basic_gray"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see "aff site : gov"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    And I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see "aff site : gov"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"

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
    And I attach the file "features/support/very_large.jpg" to "Page background image"
    And I press "Save for Preview"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see "Search results page title can't be blank"
    And I should see "Page background image file size must be under 512 KB"
    And I should see "Title link color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits"

  Scenario: Editing look and feel and make it live on a site with one serp
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | search_button_text_color | search_button_background_color | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp | show_content_border | show_content_box_shadow |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #111111                  | #0000EE                        | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #008000        | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | true          | false               | false                   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                              | {SiteName} : {Query}              |
      | Favicon URL                                                            | cdn.agency.gov/staged_favicon.ico |
      | Page background color                                                  | #EEEEEE                           |
      | Content background color                                               | #D6D6D6                           |
      | Content border color                                                   | #D8D8D8                           |
      | Content box shadow color                                               | #777777                           |
      | Search button text color                                               | #222222                           |
      | Search button background color                                         | #00DD00                           |
      | Left tab text color                                                    | #AAAAAA                           |
      | Title link color                                                       | #888888                           |
      | Visited title link color                                               | #0000f0                           |
      | Description text color                                                 | #DDDDDD                           |
      | URL link color                                                         | #007000                           |
    And I attach the file "features/support/bg.png" to "Page background image"
    And I select "repeat-y" from "Page background image repeat"
    And I select "Helvetica, sans-serif" from "Font family"
    And I check "Add top padding"
    And I check "Add drop shadow"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"
    And I should not see "View Staged"

    When I follow "View Current"
    Then I should see "aff site : gov"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with internal CSS "bg.png"
    And the page body should match "background:\ \#EEEEEE\ url\(.+\) repeat\-y"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"

    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then the "Font family" field should contain "Helvetica, sans-serif"
    And the "Page background image repeat" field should contain "repeat-y"
    And the "Page background color" field should contain "#EEEEEE"
    And the "Content background color" field should contain "#D6D6D6"
    And the "Add top padding" checkbox should be checked
    And the "Content border color" field should contain "#D8D8D8"
    And the "Add drop shadow" checkbox should be checked
    And the "Content box shadow color" field should contain "#777777"
    And the "Search button text color" field should contain "#222222"
    And the "Search button background color" field should contain "#00DD00"
    And the "Left tab text color" field should contain "#AAAAAA"
    And the "Title link color" field should contain "#888888"
    And the "Visited title link color" field should contain "#0000f0"
    And the "Description text color" field should contain "#DDDDDD"
    And the "URL link color" field should contain "#007000"
    And I should see "bg.png" image

  Scenario: Deleting page background image and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I attach the file "features/support/bg.png" to "Page background image"
    And I fill in "Page background color" with "#FEDCBA"
    And I press "Make Live"
    Then I should see "Updated changes to your live site successfully"

    When I follow "View Current"
    Then the page body should contain "background: #FEDCBA url"
    And the page body should contain "bg.png"

    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    And I check "Mark page background image for deletion"
    And I press "Make Live"
    Then I should see "Updated changes to your live site successfully"

    When I follow "View Current"
    Then the page body should contain "background-color: #FEDCBA"
    And the page body should not contain "background: #FEDCBA url"
    And the page body should not contain "bg.png"

  Scenario: Updating theme and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | search_button_text_color | search_button_background_color | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp | theme   | staged_theme |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #111111                  | #0000EE                        | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #008000        | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | true          | natural | gray         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    Then the "Grand Canyon" theme should be selected
    When I choose "Virgin Islands"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"
    When I follow "Look and feel"
    Then the "Virgin Islands" theme should be selected

   Scenario: Editing look and feel and make it live on a site with legacy template and existing header/footer
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                              | {SiteName} : {Query}              |
      | Favicon URL                                                            | cdn.agency.gov/staged_favicon.ico |
    And I choose "Basic Gray"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"
    And I should not see "View Staged"

    When I follow "View Current"
    Then I should see "aff site : gov"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"

    Scenario: Editing look and feel and make it live on a site with legacy template without existing header/footer
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | favicon_url                       | external_css_url                 | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header    | Old footer    | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title                                       | {SiteName} : {Query}              |
      | Favicon URL                                                     | cdn.agency.gov/staged_favicon.ico |
    And I choose "Basic Gray"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"
    And I should not see "View Staged"

    When I follow "View Current"
    Then I should see "aff site : gov"
    And I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should not see the page with affiliate stylesheet "default"

  Scenario: Editing look and feel with problem and make it live
    Given the following Affiliates exist:
      | display_name     | name            | domains       | contact_email         | contact_name        | uses_one_serp |
      | aff site         | aff.gov         | example.org   | aff@bar.gov           | John Bar            | true          |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    And I fill in the following:
      | Search results page title      |                       |
      | Search button text color       | #DDDD                 |
      | Search button background color | invalid color         |
      | Left tab text color            | invalid color         |
      | Title link color               | invalid color         |
      | Visited title link color       | invalid visited color |
      | Description text color         | invalid color         |
      | URL link color                 | invalid color         |
    And I attach the file "features/support/very_large.jpg" to "Page background image"
    And I press "Make Live"
    Then I should see "Look and Feel of the Search Results Page" within "title"
    And I should see "Search results page title can't be blank"
    And I should see "Page background image file size must be under 512 KB"
    And I should see "Search button text color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Search button background color should consist of a # character followed by 3 or 6 hexadecimal digits"
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
    When I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"
    When I follow "View Staged"
    Then I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    And I should see "Live Search Results"
    And I should see 10 search results

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
    When I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"
    When I follow "View Staged"
    Then I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with affiliate stylesheet "default"
    And I should see "Staged Search Results"

  Scenario: Resetting style on a site with one serp
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | search_button_text_color | search_button_background_color | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | favicon_url                       | external_css_url                 | header     | footer     | staged_header | staged_footer | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #111111                  | #0000EE                        | #BBBBBB             | #33ff33          | #0000ff                  | #CCCCCC                | #007000        | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | Old header | Old footer | Old header    | Old footer    | true          |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Look and feel"
    Then the "Search button text color" field should contain "#111111"
    And the "Search button background color" field should contain "#0000EE"
    And the "Left tab text color" field should contain "#BBBBBB"
    And the "Title link color" field should contain "#33ff33"
    And the "Visited title link color" field should contain "#0000ff"
    And the "Description text color" field should contain "#CCCCCC"
    And the "URL link color" field should contain "#007000"
    When I fill in the following:
      | Search button text color       |  |
      | Search button background color |  |
      | Left tab text color            |  |
      | Title link color               |  |
      | Visited title link color       |  |
      | Description text color         |  |
      | URL link color                 |  |
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"

    When I follow "Look and feel"
    Then the "Search button text color" field should contain "#FFFFFF"
    And the "Search button background color" field should contain "#00396F"
    And the "Left tab text color" field should contain "#9E3030"
    And the "Title link color" field should contain "#2200CC"
    And the "Visited title link color" field should contain "#800080"
    And the "Description text color" field should contain "#000000"
    And the "URL link color" field should contain "#008000"

  Scenario: Editing managed header/footer and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | uses_one_serp | theme   |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | true          | default |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    And the "Header text" field should contain "aff site"
    And I fill in the following:
      | Header text         | updated header without image |
      | Header home URL     | www.agency.gov               |
      | Header Link Title 0 | News                         |
      | Header Link URL 0   | news.agency.gov              |
      | Header Link Title 1 | Blog                         |
      | Header Link URL 1   | blog.agency.gov              |
      | Footer Link Title 0 | About Us                     |
      | Footer Link URL 0   | about.agency.gov             |
      | Footer Link Title 1 | Contact Us                   |
      | Footer Link URL 1   | contact.agency.gov           |
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see a link to "updated header without image" with url for "http://www.agency.gov"
    And I should see a link to "News" with url for "http://news.agency.gov" in the SERP header
    And I should see a link to "Blog" with url for "http://blog.agency.gov" in the SERP header
    And I should see a link to "About Us" with url for "http://about.agency.gov" in the SERP footer
    And I should see a link to "Contact Us" with url for "http://contact.agency.gov" in the SERP footer

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    And the "Header text" field should contain "updated header without image"
    And the "Header home URL" field should contain "http://www.agency.gov"
    And the "Header Link Title 0" field should contain "News"
    And the "Header Link URL 0" field should contain "news.agency.gov"
    And the "Header Link Title 1" field should contain "Blog"
    And the "Header Link URL 1" field should contain "blog.agency.gov"
    And the "Footer Link Title 0" field should contain "About Us"
    And the "Footer Link URL 0" field should contain "about.agency.gov"
    And the "Footer Link Title 1" field should contain "Contact Us"
    And the "Footer Link URL 1" field should contain "contact.agency.gov"

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I fill in the following:
      | Header text | updated header with image |
    And I attach the file "features/support/small.jpg" to "Header image"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see a link to "updated header with image" with url for "http://www.agency.gov"
    And I should see an image link to "logo" with url for "http://www.agency.gov"
    And I should see "small.jpg" image

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I fill in the following:
      | Header text | |
    And I attach the file "features/support/searchlogo.gif" to "Header image"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should not see "updated header with image" in the SERP header
    And I should see an image link to "logo" with url for "http://www.agency.gov"
    And I should see "searchlogo.gif" image

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I check "Mark header image for deletion"
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should not see an image with alt text "logo"

  Scenario: Editing managed header/footer with invalid input and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | theme   |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | elegant |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I fill in the following:
      | Header background color | #DDDD              |
      | Header text color       | #XXXXX             |
      | Header Link Title 0     | News               |
      | Header Link URL 0       |                    |
      | Header Link Title 1     |                    |
      | Header Link URL 1       | blog.agency.gov    |
      | Footer Link Title 0     | About Us           |
      | Footer Link URL 0       |                    |
      | Footer Link Title 1     |                    |
      | Footer Link URL 1       | contact.agency.gov |
    And I attach the file "features/support/very_large.jpg" to "Header image"
    And I press "Make Live"
    Then I should see "Header and Footer" in the page header
    And I should see "Header background color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Header text color should consist of a # character followed by 3 or 6 hexadecimal digits"
    And I should see "Header image file size must be under 512 KB"
    And I should see "Header link title can't be blank"
    And I should see "Header link URL can't be blank"
    And I should see "Footer link title can't be blank"
    And I should see "Footer link URL can't be blank"

  Scenario: Editing managed header/footer and save it for preview
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | uses_one_serp | theme   |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | true          | default |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    And the "Header text" field should contain "aff site"
    And I fill in the following:
      | Header text         | live header with image  |
      | Header home URL     | live.agency.gov         |
      | Header Link Title 0 | News                    |
      | Header Link URL 0   | news.agency.gov         |
      | Header Link Title 1 | Blog                    |
      | Header Link URL 1   | http://blog.agency.gov  |
      | Footer Link Title 0 | About Us                |
      | Footer Link URL 0   | http://about.agency.gov |
      | Footer Link Title 1 | Contact Us              |
      | Footer Link URL 1   | contact.agency.gov      |
    And I attach the file "features/support/searchlogo.gif" to "Header image"
    And I press "Make Live"
    Then I should see "Updated changes to your live site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see a link to "live header with image" with url for "http://live.agency.gov"
    And I should see an image link to "logo" with url for "http://live.agency.gov"
    And I should see "searchlogo.gif" image
    And I should see a link to "News" with url for "http://news.agency.gov" in the SERP header
    And I should see a link to "Blog" with url for "http://blog.agency.gov" in the SERP header
    And I should see a link to "About Us" with url for "http://about.agency.gov" in the SERP footer
    And I should see a link to "Contact Us" with url for "http://contact.agency.gov" in the SERP footer

    When I go to the "aff site" affiliate page
    When I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    And the "Header text" field should contain "live header with image"
    And the "Header home URL" field should contain "http://live.agency.gov"
    And the "Header Link Title 0" field should contain "News"
    And the "Header Link URL 0" field should contain "http://news.agency.gov"
    And the "Header Link Title 1" field should contain "Blog"
    And the "Header Link URL 1" field should contain "http://blog.agency.gov"
    And the "Footer Link Title 0" field should contain "About Us"
    And the "Footer Link URL 0" field should contain "http://about.agency.gov"
    And the "Footer Link Title 1" field should contain "Contact Us"
    And the "Footer Link URL 1" field should contain "http://contact.agency.gov"

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I fill in the following:
      | Header text         | updated header with existing image |
      | Header home URL     | staged.agency.gov                  |
      | Header Link Title 0 | Features                           |
      | Header Link URL 0   | features.agency.gov                |
      | Header Link Title 1 | Help                               |
      | Header Link URL 1   | help.agency.gov                    |
      | Footer Link Title 0 | Privacy                            |
      | Footer Link URL 0   | privacy.agency.gov                 |
      | Footer Link Title 1 | Policies                           |
      | Footer Link URL 1   | policies.agency.gov                |
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see a link to "updated header with existing image" with url for "http://staged.agency.gov"
    And I should see an image link to "logo" with url for "http://staged.agency.gov"
    And I should see "searchlogo.gif" image
    And I should see a link to "Features" with url for "http://features.agency.gov" in the SERP header
    And I should see a link to "Help" with url for "http://help.agency.gov" in the SERP header
    And I should see a link to "Privacy" with url for "http://privacy.agency.gov" in the SERP footer
    And I should see a link to "Policies" with url for "http://policies.agency.gov" in the SERP footer

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I fill in the following:
      | Header text | |
    And I attach the file "features/support/small.jpg" to "Header image"
    And I press "Save for Preview"
    Then I should see "Staged changes to your site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    And I should not see "updated header without image" in the SERP header
    And I should see an image link to "logo" with url for "http://staged.agency.gov"
    And I should see "small.jpg" image

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see a link to "live header with image" with url for "http://live.agency.gov"
    And I should see an image link to "logo" with url for "http://live.agency.gov"
    And I should see "searchlogo.gif" image
    And I should see a link to "News" with url for "http://news.agency.gov" in the SERP header
    And I should see a link to "Blog" with url for "http://blog.agency.gov" in the SERP header
    And I should see a link to "About Us" with url for "http://about.agency.gov" in the SERP footer
    And I should see a link to "Contact Us" with url for "http://contact.agency.gov" in the SERP footer

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I fill in the following:
      | Header text     | updated header without image |
    And I check "Mark header image for deletion"
    And I press "Save for Preview"
    Then I should see "Staged changes to your site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see a link to "updated header without image" with url for "http://staged.agency.gov"
    And I should not see an image with alt text "logo"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see a link to "live header with image" with url for "http://live.agency.gov"
    And I should see an image link to "logo" with url for "http://live.agency.gov"
    And I should see "searchlogo.gif" image
    And I should see a link to "News" with url for "http://news.agency.gov" in the SERP header
    And I should see a link to "Blog" with url for "http://blog.agency.gov" in the SERP header
    And I should see a link to "About Us" with url for "http://about.agency.gov" in the SERP footer
    And I should see a link to "Contact Us" with url for "http://contact.agency.gov" in the SERP footer

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    Then I should see "Staged content is now visible"

    When I follow "View Current"
    And I should see a link to "updated header without image" with url for "http://staged.agency.gov"
    And I should not see an image with alt text "logo"
    And I should see a link to "Features" with url for "http://features.agency.gov" in the SERP header
    And I should see a link to "Help" with url for "http://help.agency.gov" in the SERP header
    And I should see a link to "Privacy" with url for "http://privacy.agency.gov" in the SERP footer
    And I should see a link to "Policies" with url for "http://policies.agency.gov" in the SERP footer

  Scenario: Updating header/footer option from managed to custom and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    When I choose "Option 2. Use CSS/HTML code to create a custom header/footer"
    And I fill in the following:
      | Enter CSS to customize the top and bottom of your search results page. | .staged { color: green; } |
      | Enter HTML to customize the top of your search results page.           | <h1>New header</h1>       |
      | Enter HTML to customize the bottom of your search results page.        | <h1>New footer</h1>       |
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 2. Use CSS/HTML code to create a custom header/footer" radio button should be checked

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    And I should see the page with internal CSS ".header-footer .staged\{color:green\}"
    And I should see the page with affiliate stylesheet "one_serp"
    Then I should see "New header"
    And I should see "New footer"

  Scenario: Updating header/footer option from managed to custom and save it for preview
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    When I choose "Option 2. Use CSS/HTML code to create a custom header/footer"
    And I fill in the following:
      | Enter CSS to customize the top and bottom of your search results page. | .staged { color: green; } |
      | Enter HTML to customize the top of your search results page.           | <h1>New header</h1>       |
      | Enter HTML to customize the bottom of your search results page.        | <h1>New footer</h1>       |
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see the page with internal CSS ".header-footer .staged\{color:green\}"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see "New header"
    And I should see "New footer"

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    Then I should see "Staged content is now visible"

    When I follow "View Current"
    Then I should see the page with internal CSS ".header-footer .staged\{color:green\}"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see "New header"
    And I should see "New footer"

  Scenario: Editing custom header/footer and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | page_background_color | content_background_color | search_button_text_color | search_button_background_color | left_tab_text_color | title_link_color | visited_title_link_color | description_text_color | url_link_color | header_footer_css         | header     | footer     | favicon_url                | external_css_url          | uses_one_serp | uses_managed_header_footer | theme  | show_content_border | show_content_box_shadow |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | #FFFFFF               | #F2F2F2                  | #111111                  | #0000EE                        | #BBBBBB             | #33FF33          | #0000FF                  | #CCCCCC                | #009000        | .current { color: blue; } | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | true          | false                      | custom | false               | false                   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And no emails have been sent
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Header and footer"
    And I fill in the following:
      | External CSS URL                                                       | cdn.agency.gov/staged_custom.css                      |
      | Enter CSS to customize the top and bottom of your search results page. | .staged { color: green; }                             |
      | Enter HTML to customize the top of your search results page.           | New header <!--[if IE]>Hey I am using IE <![endif]--> |
      | Enter HTML to customize the bottom of your search results page.        | New footer <!--[if IE]>Hey I am using IE <![endif]--> |
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"
    When "aff@bar.gov" opens the email
    And I should see "The header and/or footer for aff site have been updated" in the email body
    And I should see "Old header" in the email body
    And I should see "Old footer" in the email body
    And I should see "New header" in the email body
    And I should see "New footer" in the email body

    When I follow "Header and footer"
    Then the "External CSS URL" field should contain "http://cdn.agency.gov/staged_custom.css"
    And the "Enter CSS to customize the top and bottom of your search results page." field should contain ".staged \{ color: green; \}"
    And the "Enter HTML to customize the top of your search results page." field should contain "New header"
    And the "Enter HTML to customize the bottom of your search results page." field should contain "New footer"
    And the "Enter HTML to customize the top of your search results page." field should not contain "Hey I am using IE"
    And the "Enter HTML to customize the bottom of your search results page." field should not contain "Hey I am using IE"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see "New header"
    And I should see "New footer"
    And I should see the page with internal CSS ".header-footer .staged\{color:green\}"
    And I should see the page with affiliate stylesheet "one_serp"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"

  Scenario: Editing custom header/footer with problem and save for preview
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | header_footer_css         | header     | footer     | favicon_url                | external_css_url          | uses_one_serp | theme   | uses_managed_header_footer |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | .current { color: blue; } | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | true          | default | false                      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Header and footer"
    And I fill in the following:
      | External CSS URL                                                       | cdn.agency.gov/staged_custom.css                                  |
      | Enter CSS to customize the top and bottom of your search results page. | .staged { invalid-css-syntax }                                    |
      | Enter HTML to customize the top of your search results page.           | <html><body>New header <style>h1{color:blue}</style></body><html> |
      | Enter HTML to customize the bottom of your search results page.        | <div>New footer</a>                                               |
    And I press "Save for Preview"
    Then I should see "Header and Footer" in the page header
    And I should see "Invalid CSS"
    And I should see "HTML to customize the top of your search results page can't contain script, style, link elements."
    And I should see "HTML to customize the bottom of your search results page is invalid"
    When I fill in the following:
      | Enter CSS to customize the top and bottom of your search results page. | .staged { color: #DDDD }                                            |
      | Enter HTML to customize the top of your search results page.           | <div>New header</a>                                                 |
      | Enter HTML to customize the bottom of your search results page.        | <html><body><style>h1{color:green}</style> New footer</body></html> |
    And I press "Save for Preview"
    Then I should see "Colors must have either three or six digits"
    And I should see "HTML to customize the top of your search results page is invalid"
    And I should see "HTML to customize the bottom of your search results page can't contain script, style, link elements."

  Scenario: Editing custom header/footer with problem and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains       | font_family         | header_footer_css         | header     | footer     | favicon_url                | external_css_url          | uses_one_serp | theme   | uses_managed_header_footer |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | oldagency.gov | Verdana, sans-serif | .current { color: blue; } | Old header | Old footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | true          | default | false                      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site"
    And I follow "Header and footer"
    And I fill in the following:
      | External CSS URL                                                       | cdn.agency.gov/staged_custom.css                                   |
      | Enter CSS to customize the top and bottom of your search results page. | .staged { invalid-css-syntax }                                     |
      | Enter HTML to customize the top of your search results page.           | <html><body>New header <style>h1{color:blue}</style></body></html> |
      | Enter HTML to customize the bottom of your search results page.        | <div>New footer</a>                                                |
    And I press "Make Live"
    Then I should see "Header and Footer" in the page header
    And I should see "Invalid CSS"
    And I should see "HTML to customize the top of your search results page can't contain script, style, link elements."
    And I should see "HTML to customize the bottom of your search results page is invalid"
    When I fill in the following:
      | Enter CSS to customize the top and bottom of your search results page. | .staged { color: #DDDD }                                            |
      | Enter HTML to customize the top of your search results page.           | <div>New header</a>                                                 |
      | Enter HTML to customize the bottom of your search results page.        | <html><body><style>h1{color:green}</style> New footer</body></html> |
    And I press "Make Live"
    Then I should see "Colors must have either three or six digits"
    And I should see "HTML to customize the top of your search results page is invalid"
    And I should see "HTML to customize the bottom of your search results page can't contain script, style, link elements."

  Scenario: Updating header/footer option from custom to managed and make it live
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | uses_managed_header_footer | header        | footer        |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | false                      | custom header | custom footer |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 2. Use CSS/HTML code to create a custom header/footer" radio button should be checked
    When I choose "Option 1. Use a managed header/footer"
    And I fill in the following:
      | Header text     | updated header without image |
      | Header home URL | www.agency.gov               |
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Current"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see a link to "updated header without image" with url for "http://www.agency.gov"
    And I should not see "custom header"
    And I should not see "custom footer"

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    And the "Header text" field should contain "updated header without image"
    And the "Header home URL" field should contain "http://www.agency.gov"

  Scenario: Updating header/footer option from custom to managed and save it for preview
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | uses_managed_header_footer |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | false                      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I choose "Option 1. Use a managed header/footer"
    And I fill in the following:
      | Header text     | updated header without image |
      | Header home URL | www.agency.gov               |
    And I press "Save for Preview"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged changes to your site successfully"

    When I go to the "aff site" affiliate page
    And I follow "View Staged"
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should see a link to "updated header without image" with url for "http://www.agency.gov"

    When I go to the "aff site" affiliate page
    And I press "Push Changes"
    Then I should see "Staged content is now visible"

    When I follow "View Current"
    Then I should see a link to "updated header without image" with url for "http://www.agency.gov"

    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "Option 1. Use a managed header/footer" radio button should be checked
    And the "Header text" field should contain "updated header without image"
    And the "Header home URL" field should contain "http://www.agency.gov"

  Scenario: Editing custom header/footer and push the changes to live
     Given the following Affiliates exist:
       | display_name | name    | contact_email | contact_name | header     | footer     | uses_managed_header_footer |
       | aff site     | aff.gov | aff@bar.gov   | John Bar     | Old header | Old footer | false                      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And no emails have been sent
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    And I fill in the following:
      | Enter HTML to customize the top of your search results page.    | New header |
      | Enter HTML to customize the bottom of your search results page. | New footer |
    And I press "Save for Preview"
    Then I should see "Staged changes to your site successfully"
    When I press "Push Changes"
    Then I should see "Staged content is now visible"
    And "aff@bar.gov" should receive an email
    When I open the email
    Then I should see "The header and/or footer for aff site have been updated" in the email body
    And I should see "Old header" in the email body
    And I should see "Old footer" in the email body
    And I should see "New header" in the email body
    And I should see "New footer" in the email body

    When I go to aff.gov's search page
    Then I should see "New header"
    And I should see "New footer"

  Scenario: Visiting the header and footer page for affiliate without external_css_url
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Look and feel"
    Then I should not see a field labeled "External CSS URL"

  Scenario: Visiting the header and footer page for affiliate with staged_external_css_url
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | staged_external_css_url          | has_staged_content |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | cdn.agency.gov/staged_custom.css | true               |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then the "External CSS URL" field should contain "http://cdn.agency.gov/staged_custom.css"

  Scenario: Visiting the header and footer page for affiliate with legacy templates
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | uses_one_serp | uses_managed_header_footer | external_css_url          |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | false         | false                      | cdn.agency.gov/custom.css |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Header and footer"
    Then I should not see a field labeled "Header text"
    When I fill in the following:
      | External CSS URL                                                       | cdn.agency.gov/staged_custom.css |
      | Enter CSS to customize the top and bottom of your search results page. | .staged { color: green; }        |
      | Enter HTML to customize the top of your search results page.           | New header                       |
      | Enter HTML to customize the bottom of your search results page.        | New footer                       |
    And I press "Make Live"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Updated changes to your live site successfully"

    When I go to aff.gov's search page
    Then I should see the page with internal CSS ".header-footer .staged\{color:green\}"
    And I should not see the page with affiliate stylesheet "one_serp"
    And I should see the page with external affiliate stylesheet "http://cdn.agency.gov/staged_custom.css"
    And I should see "New header"
    And I should see "New footer"

  Scenario: Visiting an affiliate SERP without a header
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results |
    When I go to aff.gov's search page
    Then I should see "aff site" in the SERP header

    Given the following Affiliates exist:
      | display_name | name     | contact_email | contact_name | search_results_page_title           | header |
      | aff2 site    | aff2.gov | aff2@bar.gov  | John Bar     | {Query} - {SiteName} Search Results |        |
    When I go to aff2.gov's search page
    Then I should see "aff2 site" in the SERP header

    Given the following Affiliates exist:
      | display_name | name     | contact_email | contact_name | search_results_page_title           | managed_header_text |
      | aff3 site    | aff3.gov | aff2@bar.gov  | John Bar     | {Query} - {SiteName} Search Results |                     |
    When I go to aff3.gov's search page
    Then I should not see the SERP header

    Given the following Affiliates exist:
      | display_name | name       | contact_email   | contact_name | search_results_page_title           | domains        | uses_one_serp |
      | aff4 site     | aff4.gov  | aff2@bar.gov    | John Bar     | {Query} - {SiteName} Search Results | whitehouse.gov | false         |
    When I go to aff4.gov's search page
    Then I should not see the SERP header

  Scenario: Cancelling staged changes from the Admin Center page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | affiliate_template_name | search_results_page_title | domains  | header      | footer      | favicon_url                | external_css_url          | staged_affiliate_template_name | staged_search_results_page_title | staged_header | staged_footer | staged_favicon_url                | staged_external_css_url          | has_staged_content | uses_one_serp |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | Default                 | Live Search Results       | data.gov | Live header | Live footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | Basic Gray                     | Staged Search Results            | Staged header | Staged footer | cdn.agency.gov/staged_favicon.ico | cdn.agency.gov/staged_custom.css | true               | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I press "Cancel Changes"
    Then I should see the following breadcrumbs: USASearch > Admin Center > bar site
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

  Scenario: Cancelling staged changes from the site specific Admin Center page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | search_results_page_title           | domains  | header     | footer     | favicon_url                       | external_css_url                 | uses_one_serp |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | {Query} - {SiteName} Search Results | data.gov | Old header | Old footer | http://cdn.agency.gov/favicon.ico | http://cdn.agency.gov/custom.css | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "bar site" affiliate page
    And I follow "Look and feel"
    And I fill in the following:
      | Favicon URL                                                     | cdn.agency.gov/staged_favicon.ico |
      | Search results page title                                       | updated SERP title                |
    And I choose "Basic Gray"
    And I press "Save for Preview"
    And I should see "Staged changes to your site successfully"
    Then I should see "Cancel Changes" button
    When I follow "View Staged"
    Then I should see the page with favicon "http://cdn.agency.gov/staged_favicon.ico"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should see "updated SERP title"

    When I go to the "bar site" affiliate page
    And I press "Cancel Changes"
    Then I should see the following breadcrumbs: USASearch > Admin Center > bar site
    And I should see "Staged changes were successfully cancelled."
    And I should not see "View Staged"
    And I should not see "Push Changes" button
    And I should not see "Cancel Changes" button
    When I follow "View Current"
    Then I should see the page with favicon "http://cdn.agency.gov/favicon.ico"
    And I should see the page with affiliate stylesheet "default"
    And I should see "gov - bar site Search Results"
    And I should see 10 search results

  Scenario: Cancelling staged changes from the Preview page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | affiliate_template_name | search_results_page_title | domains  | header      | footer      | favicon_url                | external_css_url          | staged_affiliate_template_name | staged_search_results_page_title | staged_header | staged_footer | staged_favicon_url                | staged_external_css_url          | has_staged_content | uses_one_serp |
      | aff site     | bar.gov | aff@bar.gov   | John Bar     | Default                 | Live Search Results       | data.gov | Live header | Live footer | cdn.agency.gov/favicon.ico | cdn.agency.gov/custom.css | Basic Gray                     | Staged Search Results            | Staged header | Staged footer | cdn.agency.gov/staged_favicon.ico | cdn.agency.gov/staged_custom.css | true               | false         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Preview"
    And I press "Cancel Staged Changes"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
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
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Preview
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
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site
    And I should see "Staged content is now visible"
    And I follow "Preview"
    And I fill in the following within "#live_site_search_form":
      | query | White House |
    And I press "Search on Live Site"
    Then I should see "Staged - aff site : White House" within "title"

  Scenario: Related searches on English SERPs for given affiliate search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following SAYT Suggestions exist for aff.gov:
      | phrase                 |
      | Some Unique Obama Term |
      | el paso term           |
    When I go to aff.gov's search page
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should see "Related Searches for obama by aff site" in the search results section
    And I should see "some unique obama term"
    And I should not see "aff.gov"

  Scenario: Related searches on Spanish SERPs for given affiliate search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | locale |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | es     |
    And the following SAYT Suggestions exist for aff.gov:
      | phrase                 |
      | Some Unique Obama Term |
      | el paso term           |
    When I go to aff.gov's search page
    And I fill in "query" with "obama"
    And I press "Buscar"
    Then I should see "Búsquedas relacionadas a obama de aff site" in the search results section
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

  Scenario: Visiting a Spanish affiliate advanced search page
    Given the following Affiliates exist:
      | display_name | name        | contact_email | contact_name | locale |
      | noindex site | noindex.gov | aff@aff.gov   | Two Bar      | es     |
    When I go to noindex.gov's search page
    And I follow "Búsqueda avanzada"
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see the browser page titled "Búsqueda avanzada - noindex site"

  Scenario: Doing an advanced affiliate search
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | domains | header           | footer           | uses_managed_header_footer | locale |
      | English aff site | en.aff.gov | aff@bar.gov   | John Bar     | usa.gov | Affiliate Header | Affiliate Footer | false                      | en     |
      | Spanish aff site | es.aff.gov | aff@bar.gov   | John Bar     | usa.gov | Affiliate Header | Affiliate Footer | false                      | es     |
    When I go to en.aff.gov's search page
    And I follow "Advanced Search"
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see "Header"
    And I should see "Footer"
    And I should see "Use the options on this page to create a very specific search"
    And I should not see "aff.gov"
    When I fill in "query" with "emergency"
    And I press "Search"
    Then I should see "Results 1-"
    And I should see "emergency"

    When I go to es.aff.gov's search page
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

    When I am on the affiliate advanced search page for "en.aff.gov"
    And I fill in "query-or" with "barack obama"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "barack OR obama"

    When I am on the affiliate advanced search page for "en.aff.gov"
    And I fill in "query-quote" with "barack obama"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "barack obama"

    When I am on the affiliate advanced search page for "en.aff.gov"
    And I fill in "query-not" with "barack"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "-barack"

    When I am on the affiliate advanced search page for "en.aff.gov"
    And I select "Adobe PDF" from "filetype"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "filetype:pdf"

    When I am on the affiliate advanced search page for "en.aff.gov"
    And I fill in "query" with "barack obama"
    And I select "20" from "per-page"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "Results 1-20"

    When I am on the affiliate advanced search page for "en.aff.gov"
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
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Get Code
    And I should see "Head Snippet"
    And I should see "Form Snippet"
    And I should see the code for English language sites
    And I should see "USASearch Tag Snippet"
    And I should see the stats code

  Scenario: Getting an embed code for my affiliate site search in Spanish
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | locale  |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            | es      |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Get code"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Get Code
    And I should see "Head Snippet"
    And I should see "Form Snippet"
    And I should see the code for Spanish language sites
    And I should see "USASearch Tag Snippet"
    And I should see the stats code

  Scenario: Navigating to an Affiliate page for a particular Affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "aff site"
    Then I should see "Site: aff site" within "title"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site
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
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Type-ahead Search
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

  Scenario: Viewing Manage Users for an affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Manage users"
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Manage Users
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
    And I should see a link to "Terms of Service" with url for "http://usasearch.howto.gov/tos" in the page content
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

  Scenario: A nonsense English affiliate search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email     | contact_name        | affiliate_template_name |
      | aff site         | aff.gov          | aff@bar.gov       | John Bar            | Default                 |
    When I go to aff.gov's search page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I press "Search"
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: A nonsense Spanish affiliate search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | locale |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | es     |
    When I go to aff.gov's search page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I press "Buscar"
    Then I should see "No hemos encontrado ningún resultado que contenga 'kjdfgkljdhfgkldjshfglkjdsfhg'. Intente usar otras palabras clave o sinónimos."

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
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Best Bets

    When I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Best Bets: Text

    When I follow "Best bets"
    And I follow "Add new text" in the affiliate boosted contents section
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Add a new Best Bets: Text

    When I follow "Best bets"
    And I follow "Bulk upload" in the affiliate boosted contents section
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Bulk Upload Best Bets: Text

    When I follow "Best bets"
    And I follow "View all" in the featured collections section
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Best Bets: Graphics

    When I follow "Best bets"
    And I follow "Add new graphics" in the featured collections section
    Then I should see the following breadcrumbs: USASearch > Admin Center > aff site > Add a new Best Bets: Graphics

  Scenario: Excluding a URL from affiliate SERPs
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains         |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | whitehouse.gov  |
    And affiliate "aff.gov" has the following RSS feeds:
      | affiliate | url                                             | name    | is_navigable |
      | aff.gov   | http://www.whitehouse.gov/feed/blog/white-house | WH Blog | true         |
    And feed "WH Blog" has the following news items:
      | link                                     | title                             | guid  | description         |
      | http://www.whitehouse.gov/our-government | Our Government \| The White House | 12345 | white house cabinet |
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
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Social Media
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

  Scenario: Editing youtube handle
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | youtube_handle |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | USAgov         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    When I follow "RSS"
    Then I should see "Videos"
    When I follow "Social Media"
    And I fill in "YouTube handle" with "     USGovernment    "
    And I press "Save"
    And I follow "RSS"
    Then I should not see "Delete" button
    When I follow "Edit"
    Then the "Name*" field should contain "Videos"
    And the "URL*" field should contain "http:\/\/gdata.youtube.com\/feeds\/base\/videos\?alt=rss&author=usgovernment"
    And the "URL*" field should be disabled
    When I follow "Social Media" in the page content
    Then I should see the browser page titled "Social Media"

  Scenario: Visiting the URLs & Sitemaps page
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "URLs & Sitemaps"
    Then I should see the browser page titled "URLs & Sitemaps"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > URLs & Sitemaps
    And I should see "URLs" in the page header
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

  Scenario: Visiting legacy affiliate with oneserp parameter
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | uses_one_serp |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | false         |
    When I go to aff.gov's oneserp search page
    Then I should see the page with affiliate stylesheet "one_serp"

  Scenario: Visiting sidebar
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | results_source |
      | aff site       | aff.gov          | aff@bar.gov   | John Bar     | bing+odie      |
      | bing only site | bingonly.aff.gov | aff@bar.gov   | John Bar     | bing           |
    And affiliate "aff.gov" has the following RSS feeds:
      | name          | url                                                | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press               | true         |
    And affiliate "aff.gov" has the following document collections:
      | name | prefixes             | is_navigable |
      | FAQs | http://aff.gov/faqs/ | true         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Sidebar"
    Then I should see the browser page titled "Sidebar"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Sidebar
    And I should see "Sidebar" in the page header
    And I should see "USASearch/Bing" in the page content

    When I go to the "aff site" affiliate page
    And I follow "Sidebar"
    And I follow "RSS" in the page content
    Then I should see "Press"
    And I should see "http://www.whitehouse.gov/feed/press"

    When I go to the "aff site" affiliate page
    And I follow "Sidebar"
    And I follow "Collection" in the page content
    Then I should see "FAQs"
    And I should see "http://aff.gov/faqs/"

    When I go to the "aff site" affiliate page
    And I follow "Sidebar"
    And I follow "Add new collection" in the page content
    Then I should see "Add a new Collection" in the page header

    When I go to the "aff site" affiliate page
    And I follow "Sidebar"
    And I follow "Add new RSS feed" in the page content
    Then I should see "Add a new RSS Feed" in the page header

    When I go to the "bing only site" affiliate page
    And I follow "Sidebar"
    Then I should not see "Add new collection"

  Scenario: Editing sidebar
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | name          | url                                                | position | is_navigable |
      | Hide Me       | http://www.whitehouse.gov/feed/media/photo-gallery | 2        | false        |
      | Press         | http://www.whitehouse.gov/feed/press               | 0        | true         |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | 1        | true         |
    And affiliate "aff.gov" has the following document collections:
      | name   | prefixes               | position | is_navigable |
      | Topics | http://aff.gov/topics/ | 2        | true         |
      | FAQs   | http://aff.gov/faqs/   | 0        | true         |
      | Help   | http://aff.gov/help/   | 1        | false        |
    When I go to aff.gov's search page
    Then I should see "Everything Images Press Photo Gallery FAQs Topics" in the left column
    And I should not see "Hide Me" in the left column
    When I follow "Press" in the left column
    Then I should see "All Time" in the left column

    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "Sidebar"
    Then the "Default search label" field should contain "Everything"
    And the "Image search label" field should contain "Images"
    And the "Is image search enabled" checkbox should be checked
    And the "RSS feed 0" field should contain "Press"
    And the "Is RSS feed 0 navigable" checkbox should be checked
    And the "RSS feed 1" field should contain "Photo Gallery"
    And the "Is RSS feed 1 navigable" checkbox should be checked
    And the "RSS feed 2" field should contain "Hide Me"
    And the "Is RSS feed 2 navigable" checkbox should not be checked
    And the "Document collection 0" field should contain "FAQs"
    And the "Is document collection 0 navigable" checkbox should be checked
    And the "Document collection 1" field should contain "Help"
    And the "Is document collection 1 navigable" checkbox should not be checked
    And the "Document collection 2" field should contain "Topics"
    And the "Is document collection 2 navigable" checkbox should be checked
    And the "Show by time period module" checkbox should be checked

    When I fill in the following:
      | Default search label  | Web       |
      | Image search label    | Pictures  |
      | RSS feed 0            | News      |
      | RSS feed 1            | Galleries |
      | Document collection 0 | Q&A       |
    And I press "Save"
    Then I should see "Site was successfully updated."

    When I go to aff.gov's search page
    Then I should see "Web Pictures News Galleries Q&A Topics" in the left column
    When I follow "News" in the left column
    Then I should see "All Time" in the left column

    When I go to the "aff site" affiliate page
    And I follow "Sidebar"
    And I uncheck "Is image search enabled"
    And I uncheck "Is RSS feed 1 navigable"
    And I check "Is RSS feed 2 navigable"
    And I uncheck "Is document collection 0 navigable"
    And I check "Is document collection 1 navigable"
    And I uncheck "Show by time period module"
    And I press "Save"
    Then I should see "Site was successfully updated."

    When I go to aff.gov's search page
    Then I should see "Web News Hide Me Help Topics" in the left column
    And I should not see "Galleries" in the left column
    And I should not see "Q&A" in the left column

    When I follow "Hide Me" in the left column
    Then I should not see "All Time" in the left column

  Scenario: Setting RSS feed name to blank when Editing sidebar
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | name          | url                                                | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press               | true         |
    And affiliate "aff.gov" has the following document collections:
      | name | prefixes             | is_navigable |
      | FAQs | http://aff.gov/faqs/ | true         |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Sidebar"
    And I fill in the following:
      | RSS feed 0            |  |
      | Document collection 0 |  |
    And I press "Save"
    Then I should see "Rss feeds name can't be blank"
    And I should see "Document collections name can't be blank"

  Scenario: Visiting legacy affiliate with oneserp and strictui parameters
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | uses_one_serp | external_css_url                | header                                                                  | footer                                                                  |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | false         | http://cdn.aff.gov/external.css | <style>#my_header { color:red } </style> <h1 id='my_header'>header</h1> | <style>#my_footer { color:red } </style> <h1 id='my_footer'>footer</h1> |
    When I go to aff.gov's oneserp with strictui search page
    Then I should see the page with affiliate stylesheet "one_serp"
    And I should not see the page with external affiliate stylesheet "http://cdn.aff.gov/external.css"
    And I should not see tainted SERP header
    And I should not see tainted SERP footer

  Scenario: Viewing an affiliate admin center page with a help links
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following Help Links exist:
      | action_name           | help_page_url               |
      | edit_site_information | http://usasearch.howto.gov/ |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Site information"
    Then I should see "help-icon.png" image

    When I follow "RSS"
    Then I should not see "help-icon.png" image

  Scenario: Visiting the results modules
    Given the following Affiliates exist:
      | display_name   | name             | contact_email | contact_name |
      | aff site       | aff.gov          | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | name          | url                                                | position | shown_in_govbox |
      | Press         | http://www.whitehouse.gov/feed/press               | 0        | true            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "Results modules"
    Then I should see the browser page titled "Results Modules"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Results Modules
    And I should see "Results Modules" in the page header
    When I follow "Add new RSS feed" in the page content
    Then I should see "Add a new RSS Feed" in the page header

    When I follow "Results modules"
    And I follow "Press" in the page content
    Then I should see "http://www.whitehouse.gov/feed/press"

    When I follow "Results modules"
    And I follow "RSS" in the page content
    Then I should see "http://www.whitehouse.gov/feed/press"

  Scenario: Editing the results modules
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | locale |
      | aff site     | aff.gov    | aff@bar.gov   | John Bar     | en     |
      | Spanish site | es.aff.gov | aff@bar.gov   | John Bar     | es     |
    And affiliate "aff.gov" has the following RSS feeds:
      | name          | url                                                | position | shown_in_govbox |
      | Press         | http://www.whitehouse.gov/feed/press               | 0        | true            |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | 1        | true            |
      | Not in GovBox | http://www.whitehouse.gov/feed/media/photo-gallery | 2        | false           |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | item First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | item Next news item for the feed  |
    And feed "Photo Gallery" has the following news items:
      | link                             | title      | guid  | published_ago | description                      |
      | http://www.whitehouse.gov/news/3 | Third item | uuid3 | day           | item Next news item for the feed |
    And feed "Not in Govbox" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/3 | Fourth item | uuid4 | week          | item More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fifth item  | uuid5 | week          | item Last news item for the feed  |
    And the following SAYT Suggestions exist for aff.gov:
      | phrase           |
      | some unique item |
    When I go to aff.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    Then I should see "News for 'item' by aff site"
    And I should see "First item" in the rss feed govbox
    And I should see "Second item" in the rss feed govbox
    And I should see "Third item" in the rss feed govbox
    And I should not see "Fourth item" in the rss feed govbox
    And I should not see "Fifth item" in the rss feed govbox
    Then I should see "Related Searches for item by aff site" in the search results section
    And I should see "some unique item"

    When I am logged in with email "aff@bar.gov" and password "random_string"
    And I go to the "aff site" affiliate page
    And I follow "Results modules"
    And I should see the following table rows:
      | Name          | Source    |
      | Agency        | USASearch |
      | Medline       | USASearch |
      | Press         | RSS       |
      | Photo Gallery | RSS       |
      | Not in GovBox | RSS       |
    And the "Is agency govbox enabled" checkbox should not be checked
    And the "Is medline govbox enabled" checkbox should not be checked
    And the "Show RSS feed 0 in govbox" checkbox should be checked
    And the "Show RSS feed 1 in govbox" checkbox should be checked
    And the "Show RSS feed 2 in govbox" checkbox should not be checked
    And the "Is related searches enabled" checkbox should be checked
    And I uncheck "Show RSS feed 0 in govbox"
    And I check "Show RSS feed 2 in govbox"
    And I uncheck "Is related searches enabled"
    And I fill in "Connection label 0" with "Search in Spanish"
    And I select "Spanish site" from "Site 0"
    And I press "Save"
    Then I should see "Site was successfully updated."

    When I go to aff.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    And I should see "News for 'item' by aff site"
    And I should not see "First item" in the rss feed govbox
    And I should not see "Second item" in the rss feed govbox
    And I should see "Third item" in the rss feed govbox
    And I should see "Fourth item" in the rss feed govbox
    And I should see "Fifth item" in the rss feed govbox
    Then I should not see "Related Searches for item by aff site" in the search results section
    And I should not see "some unique item"
    When I follow "Search in Spanish"
    Then I should see the browser page titled "item - Spanish site Search Results"

  Scenario: Validation in the Results modules
    Given the following Affiliates exist:
      | display_name | name            | contact_email | contact_name | locale |
      | English site | en.aff.gov      | aff@bar.gov   | John Bar     | en     |
      | Spanish site | es.aff.gov      | aff@bar.gov   | John Bar     | es     |
      | Another site | another.aff.gov | aff@bar.gov   | John Bar     | en     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "English site" affiliate page
    And I follow "Results modules"
    And I fill in "Connection label 0" with "Search in Spanish"
    And I press "Save"
    Then I should see "Related site can't be blank"
    When I select "Spanish site" from "Site 0"
    And I fill in "Connection label 0" with ""
    And I press "Save"
    Then I should see "Related site label can't be blank"

  Scenario: Editing 3rd Party Tracking
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "3rd Party Tracking"
    Then I should see the browser page titled "3rd Party Tracking"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > 3rd Party Tracking
    And I should see "3rd Party Tracking" in the page header

    When I fill in the following:
      | JavaScript URL  | search.usa.gov/javascripts/webtrends_english.js |
      | DCSIMG Hash     | MY_DCSIMG_HASH                                  |
      | DCSSIP          | MY_DCSSIP                                       |
      | Web Property ID | UA-XXXXX-XX                                     |
    And I press "Save"
    Then I should see "Site was successfully updated."

    When I go to aff.gov's search page
    Then the page body should contain "http://search.usa.gov/javascripts/webtrends_english.js"
    And the page body should contain "MY_DCSIMG_HASH"
    And the page body should contain "MY_DCSSIP"
    And the page body should contain "UA-XXXXX-XX"

    When I go to the "aff site" affiliate page
    And I follow "3rd Party Tracking"
    Then the "JavaScript URL" field should contain "http://search.usa.gov/javascripts/webtrends_english.js"
    And the "DCSIMG Hash" field should contain "MY_DCSIMG_HASH"
    And the "DCSSIP" field should contain "MY_DCSSIP"
    And the "Web Property ID" field should contain "UA-XXXXX-X"

  Scenario: Editing some of WebTrends fields
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the "aff site" affiliate page
    And I follow "3rd Party Tracking"
    And I fill in the following:
      | JavaScript URL  | http://search.usa.gov/javascripts/webtrends_english.js |
    And I press "Save"
    Then I should see the browser page titled "3rd Party Tracking"
    And I should see "JavaScript URL, DCSIMG Hash and DCSSIP are required if you are using WebTrends."

    When I fill in the following:
      | JavaScript URL |           |
      | DCSSIP         | MY_DCSSIP |
    And I press "Save"
    Then I should see the browser page titled "3rd Party Tracking"
    And I should see "JavaScript URL, DCSIMG Hash and DCSSIP are required if you are using WebTrends."

    When I fill in the following:
      | JavaScript URL |           |
      | DCSIMG Hash    |           |
      | DCSSIP         | MY_DCSSIP |
    And I press "Save"
    Then I should see the browser page titled "3rd Party Tracking"
    And I should see "JavaScript URL, DCSIMG Hash and DCSSIP are required if you are using WebTrends."
