Feature: I14y Search - redesign
  In order to get government-related search results
  As a site visitor to a site using the redesigned Search.gov search engine
  I want to be able to search for multiple types of data

  Background:
    Given the following SearchGov Affiliates exist:
      | display_name   | name           | contact_email      | first_name | last_name | domains            |
      | HealthCare.gov | healthcare.gov | aff@healthcare.gov | Jane       | Bar       | www.healthcare.gov |

  @javascript
  Scenario: Search with I14y results
    Given there are results for the "searchgov" drawer
    When I am on healthcare.gov's redesigned search page with "marketplace" query
    Then I should see exactly "20" web search results
    And I should see "More info on Health Insurance"
