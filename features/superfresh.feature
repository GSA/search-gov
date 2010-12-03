Feature: Affiliate Superfresh Interface
  In order to give affiliates the ability to submit a URL for on-demand indexing by Bing
  As an affiliate
  I want to see and manage my Superfresh URLs

  Scenario: Submit a URL for on-demand indexing
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page
    And I should see "Add to Bing"
    When I fill in "Url" with "http://new.url.com"
    And I press "Submit"
    Then I should be on the affiliate superfresh page
    And I should see "Successfully added http://new.url.com."
    And I should see "Uncrawled URLs (1)"
    And I should see "http://new.url.com" within ".uncrawled-url"
  
    When the user agent is the MSNbot
    And I call the superfresh feed
    Then I should see "http://new.url.com"
    
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should see "Uncrawled URLs (0)"
    And I should see "http://new.url.com" within ".crawled-url"

  Scenario: Submitting a bad URL for on-demand indexing
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Add to Bing"
    Then I should be on the affiliate superfresh page
    And I should see "Add to Bing"
    When I fill in "Url" with ""
    And I press "Submit"
    Then I should be on the affiliate superfresh page
    And I should see "There was an error adding the URL to be refreshed."