Feature: Affiliate site domain
  As an affiliate manager
  I want to manage my site domains
  So that I can limit search results to web pages that belong to my sites

  Scenario: Visiting site domains index page
    Given the following Affiliates exist:
      | display_name | name       | contact_email                | contact_name |
      | agency site  | agency.gov | affiliate_manager@agency.gov | John Bar     |
    And I am logged in with email "affiliate_manager@agency.gov" and password "random_string"
    When I go to the affiliate admin page with "agency.gov" selected
    And I follow "Domains"
    Then I should see the browser page titled "Domains"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Domains
    And I should see "Domains to Search" in the page header
    And I should see "Site agency site has no domain entry"

    When the following site domains exist for the affiliate agency.gov:
      | domain         | site_name       |
      | whitehouse.gov | The White House |
      | usa.gov        |                 |
    And I go to the affiliate admin page with "agency.gov" selected
    And I follow "Domains"
    Then I should see the following table rows:
      | Site Name       | Domain         |
      | usa.gov         | usa.gov        |
      | The White House | whitehouse.gov |

  Scenario: Adding, editing and deleting site domain
    Given the following Affiliates exist:
      | display_name | name       | contact_email                | contact_name |
      | agency site  | agency.gov | affiliate_manager@agency.gov | John Bar     |
    And the following site domains exist for the affiliate agency.gov:
      | domain      |
      | www.usa.gov |
    And I am logged in with email "affiliate_manager@agency.gov" and password "random_string"
    When I go to the affiliate admin page with "agency.gov" selected
    And I follow "Domains"
    And I follow "Add new domain"
    Then I should see the browser page titled "Add a new domain"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Add a new domain
    And I should see "Add a new domain" in the page header
    When I fill in the following:
      | Domain    | whitehouse.gov  |
      | Site name | The White House |
    And I press "Add"
    Then I should see "Domain was successfully added."
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Domains
    And I should see the following table rows:
      | Site Name       | Domain         |
      | The White House | whitehouse.gov |
    When I follow "Edit"
    Then I should see the browser page titled "Edit domain"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Edit domain

    When I fill in the following:
      | Domain |  |
    And I press "Save"
    Then I should see "Domain is invalid"
    When I follow "Cancel"
    Then I should see the browser page titled "Domains"

    When I follow "Edit"
    And I fill in the following:
      | Domain    | usa.gov       |
      | Site name | US Government |
    And I press "Save"
    Then I should see "Domain was successfully updated."

    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Domains
    And I should see the following table rows:
      | Site Name     | Domain  |
      | US Government | usa.gov |
    And I should not see "www.usa.gov"
    When I press "Delete"
    Then I should see "Domain was successfully deleted."
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Domains
    And I should see "Site agency site has no domain entry"

  Scenario: Bulk uploading site domains without exisiting site domains
    Given the following Affiliates exist:
      | display_name | name       | contact_email                | contact_name |
      | agency site  | agency.gov | affiliate_manager@agency.gov | John Bar     |
    And I am logged in with email "affiliate_manager@agency.gov" and password "random_string"
    When I go to the affiliate admin page with "agency.gov" selected
    And I follow "Domains"
    And I follow "Bulk upload"
    Then I should see the browser page titled "Bulk upload domains"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Bulk upload domains
    And I should see "Bulk upload domains" in the page header
    When I attach the file "features/support/site_domains.csv" to "site_domains"
    And I press "Upload"
    Then I should see the browser page titled "Domains"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Domains
    And I should see "Domains to Search" in the page header
    And I should see "Successfully uploaded 4 domains."
    And I should see the following table rows:
      | Site Name        | Domain         |
      | The White House  | whitehouse.gov |
      | 3rd USA.gov site | www3.usa.gov   |
      | 2nd USA.gov site | www2.usa.gov   |
      | www1.usa.gov     | www1.usa.gov   |

  Scenario: Bulk uploading site domains with existing site domains
    Given the following Affiliates exist:
      | display_name | name       | contact_email                | contact_name |
      | agency site  | agency.gov | affiliate_manager@agency.gov | John Bar     |
    And the following site domains exist for the affiliate agency.gov:
      | domain             | site_name        |
      | www.whitehouse.gov | The White House  |
      | www3.usa.gov       | 3rd USA.gov site |
      | www2.usa.gov       | 2nd USA.gov site |
      | www1.usa.gov       | 1st USA.gov site |
      | www.gsa.gov        | GSA              |
    And I am logged in with email "affiliate_manager@agency.gov" and password "random_string"
    When I go to the affiliate admin page with "agency.gov" selected
    And I follow "Domains"
    And I follow "Bulk upload"
    Then I should see the browser page titled "Bulk upload domains"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Bulk upload domains
    And I should see "Bulk upload domains" in the page header
    When I attach the file "features/support/site_domains_without_subdomain.csv" to "site_domains"
    And I press "Upload"
    Then I should see the browser page titled "Domains"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > agency site > Domains
    And I should see "Domains to Search" in the page header
    And I should see "Successfully uploaded 2 domains."
    And I should see the following table rows:
      | Site Name      | Domain         |
      | whitehouse.gov | whitehouse.gov |
      | usa.gov        | usa.gov        |
      | GSA            | www.gsa.gov    |
