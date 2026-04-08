Feature: Activate Search

  Scenario: Getting an embed code for my affiliate site search
    Given the following BingV7 Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | use_redesigned_results_page |
      | aff site     | aff.gov | aff@bar.gov   | John       | Bar       | false                       |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Activate Search page
    Then I should see "Form Snippet"
    And I should see the code for English language sites

  Scenario: Getting an embed code for my affiliate site search in Spanish
    Given the following BingV7 Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | locale | use_redesigned_results_page |
      | aff site     | aff.gov | aff@bar.gov   | John       | Bar       | es     | false                       |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Activate Search page
    Then I should see the code for Spanish language sites

  Scenario: Visiting the Site API Access Key
    Given the following BingV7 Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name      | api_access_key | use_redesigned_results_page |
      | aff site     | aff.gov | aff@bar.gov   | John       | Bar            | MY_AWESOME_KEY | false                       |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Activate Search page
    And I follow "API Access Key"
    Then I should see "MY_AWESOME_KEY"
