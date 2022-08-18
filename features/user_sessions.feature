Feature: User sessions

  @javascript
  Scenario: Already logged-in user visits login page
    Given I am logged in with email "affiliate_admin@fixtures.org"
    And I go to the login page
    Then I should be on the admin home page

  Scenario: Affiliate manager should be on the site home page upon successful login
    When I log in with email "affiliate_manager@fixtures.org"
    Then I should be on the gobiernousa's Dashboard page

  Scenario: Affiliate admin should be on the admin home page upon successful login
    When I log in with email "affiliate_admin@fixtures.org"
    Then I should be on the admin home page

  Scenario: User is not approved
    When I log in with email "affiliate_manager_with_not_approved_status@fixtures.org"
    Then I should see "Security Notification"
    And I should see "These credentials are not recognized as valid for accessing Search.gov. Please reach out to search@gsa.gov if you believe this is in error."

  Scenario: User's session expires after 1 hour
    Given the following Users exist:
      | first_name | last_name | email            | approval_status |
      | Jane       | doe       | jane@example.com | approved        |
    And the time is 2017-03-30 10:55
    And I am logged in with email "jane@example.com"
    And the time becomes 2017-03-30 12:00
    And I follow "Add Site"
    Then I should be on the login page

  @javascript
  Scenario: Already logged-in super admin logs out
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the admin home page
    Then I should not see "Security Notification"
    When I follow "Sign Out"
    And I go to the admin home page
    Then I should see "Security Notification"

  @javascript
  Scenario: Already logged-in user logs out
    Given I am logged in with email "affiliate_manager@fixtures.org"
    When I go to the usagov's Dashboard page
    Then I should not see "Security Notification"
    When I sign out
    And I go to the usagov's Dashboard page
    Then I should see "Security Notification"
  
  @javascript
  Scenario: User sees the header with USWDS banner
    When I go to the login page
    Then I should see "An official website of the United States government"
    When I press "Here’s how you know"
    Then I should see "Official websites use .gov"
    And I should see "A .gov website belongs to an official government organization in the United States."
    And I should see "Secure .gov websites use HTTPS"
    And I should see "A lock"
    And I should see "https:// means you’ve safely connected to the .gov website. Share sensitive information only on official, secure websites."
  
  @javascript
  Scenario: User sees the footer's Our Service section
    When I go to the login page
    Then I should see "Our Service"
    And I should see a link to "https://search.gov/about/" with text "About Us"
    And I should see a link to "https://search.gov/about/customers.html" with text "Customers"
    And I should see a link to "https://search.gov/about/policy/" with text "Search.gov in Policy"
    And I should see a link to "https://search.gov/about/feedback.html" with text "Submit Feature Requests"
    
  @javascript
  Scenario: User sees the footer's Our System section
    When I go to the login page
    And I should see "Our System"
    And I should see a link to "https://search.gov/about/updates/releases/" with text "Release Notes"
    And I should see a link to "https://search.gov/about/updates/roadmap/" with text "Product Roadmap"
    And I should see a link to "https://search.gov/about/security.html" with text "Security and Compliance"
    And I should see a link to "https://search.gov/developer/" with text "For Developers"
    And I should see a link to "https://search.gov/about/policy/tos.html" with text "Terms of Service"

  @javascript
    Scenario: User sees the footer's Contact Us section
    When I go to the login page
    And I should see "Contact Us"
    And I should see a link to "mailto:search@gsa.gov" with text "Email"
    And I should see a link to "https://search.gov/tel:(202)-969-7426" with text "Phone"

  @javascript
    Scenario: User sees the footer's More TTS Services section
    When I go to the login page
    And I should see "More TTS Services"
    And I should see a link to "https://digital.gov/guides/dap/" with text "Digital Analytics Program"
    And I should see a link to "https://federalist.18f.gov/" with text "Federalist"
    And I should see a link to "https://cloud.gov/" with text "Cloud.gov"
    And I should see a link to "https://login.gov/" with text "Login.gov"
    And I should see a link to "https://www.gsa.gov/about-us/organization/federal-acquisition-service/technology-transformation-services/tts-solutions" with text "More TTS Solutions"

    
  @javascript
    Scenario: User sees the footer's search.gov section
    When I go to the login page
    And I should see "An official website of the GSA's"
    And I should see a link to "https://gsa.gov/tts" with text "Technology Transformation Services"
    And I should see a link to "https://www.gsa.gov/about-us" with text "About GSA"
    And I should see a link to "https://www.gsa.gov/website-information/accessibility-aids" with text "Accessibility support"
    And I should see a link to "https://www.gsa.gov/reference/freedom-of-information-act-foia" with text "FOIA requests"
    And I should see a link to "https://www.gsa.gov/reference/civil-rights-programs/notification-and-federal-employee-antidiscrimination-and-retaliation-act-of-2002" with text "No FEAR Act data"
    And I should see a link to "https://www.gsaig.gov/" with text "Office of the Inspector General"
    And I should see a link to "https://www.gsa.gov/reference/reports/budget-performance" with text "Performance reports"
    And I should see a link to "https://www.gsa.gov/website-information/website-policies" with text "Website policies"
    And I should see "Looking for U.S. government information and services?"
    And I should see a link to "https://www.usa.gov/" with text "Visit USA.gov"
