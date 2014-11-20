Feature: Activate Search

  Scenario: Getting an embed code for my affiliate site search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Activate Search page
    Then I should see "Form Snippet"
    And I should see "Type-ahead search and USASearch Tag Snippet"
    And I should see the code for English language sites

  Scenario: Getting an embed code for my affiliate site search in Spanish
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | locale |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | es     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Activate Search page
    Then I should see the code for Spanish language sites

  Scenario: Visiting the Site API Access Key
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | api_access_key |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | MY_AWESOME_KEY |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Activate Search page
    And I follow "API Access Key"
    Then I should see "MY_AWESOME_KEY"

  Scenario: Visiting the Site API Pages
    Given affiliate "usagov" has the following RSS feeds:
      | name   | url                              |
      | News-1 | http://www.usa.gov/feed/news-1 |
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the usagov's Activate Search page
    And I follow "API Instructions"
    Then I should see "API Instructions"
    And I should see a link to "Terms of Service" with url for "http://search.digitalgov.gov/tos" in the API TOS section
