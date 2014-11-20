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

  Scenario: Visiting the Site API Instructions
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | name   | url                            |
      | News-1 | http://www.usa.gov/feed/news-1 |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Activate Search page
    And I follow "API Instructions"
    Then I should see "API (v2) Instructions" within the Admin Center content

    When I follow "instructions" within the Admin Center content
    Then I should see "Legacy API (v1) Instructions"

    When I follow "API (v2) Instructions"
    Then I should see "API (v2) Instructions" within the Admin Center content
