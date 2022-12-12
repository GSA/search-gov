Feature: Search (redesign)
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information on the redesigned Search page

  Background:
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       |

  @javascript
  Scenario: Search with a blank query on an affiliate page
    When I am on bar.gov's redesigned search page with "" query
    Then I should see "Please enter a search term in the box above."