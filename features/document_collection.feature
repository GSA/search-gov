Feature: Document Collections
  As an Affiliate Admin
  I want to manage groups of indexed documents
  So that my search users can navigate/filter/browse my indexed douments more easily

  Scenario: Visiting affiliate center as an Odie-less affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    And affiliate "noaa.gov" has a result source of "bing"
    When I go to the affiliate admin page with "noaa.gov" selected
    Then I should not see "Collections"

  Scenario: Visiting Affiliate Document Collections index page as a new Odie affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    And affiliate "noaa.gov" has a result source of "bing+odie"
    When I go to the affiliate admin page with "noaa.gov" selected
    And I follow "Collections"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > Noaa Site > Collections
    And I should see "Collections" in the page header
    And I should see "Site Noaa Site has no Collections"

  Scenario: Administering a Featured Collection
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    And affiliate "noaa.gov" has a result source of "bing+odie"
    When I go to the affiliate admin page with "noaa.gov" selected
    And I follow "Collections"
    And I follow "Add new collection"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > Noaa Site > Add a new Collection
    And I should see "Add a new Collection" in the page header
    When I follow "Cancel"
    Then I should see "Collections" in the page header

    When I follow "Add new collection"
    And I fill in the following:
      | Name*                 | My Collection                    |
      | URL Prefix 0          | http://www.gov.gov/              |
      | URL Prefix 1          | www.zzz.gov                      |
    And I press "Add"
    Then I should see "Collection successfully added"
    And I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > Noaa Site > Collection
    And I should see "Collections" in the page header
    And I should see "My Collection"
    And I should see "http://www.gov.gov/"
    And I should see "http://www.zzz.gov/"
    When I follow "Edit"
    Then I should see the following breadcrumbs: USASearch > Affiliate Program > Affiliate Center > Noaa Site > Edit Collections entry
    And I should see "Edit Collections entry" in the page header
    And the "Name*" field should contain "My Collection"
    And the "URL Prefix 0" field should contain "http://www.gov.gov/"
    And I fill in the following:
      | Name*                 | My Edited Collection                    |
      | URL Prefix 0          | http://www.gov.gov/edited               |
      | URL Prefix 1          |                                         |
    And I press "Update"
    Then I should see "Collections entry successfully updated."
    And I should see "My Edited Collection"
    And I should see "http://www.gov.gov/edited"
    And I should not see "http://www.zzz.gov/"

    When I follow "Edit"
    And I fill in the following:
      | Name*                 | My Edited Collection                    |
      | URL Prefix 0          | http://www.gov.gov/this_is_way_too_long/this_is_way_too_long/this_is_way_too_long/this_is_way_too_long/this_is_way_too_long/this_is_way_too_long/   |
    And I press "Update"
    Then I should see "prefix is too long (maximum is 100 characters)"

    When I fill in the following:
      | Name*                 |                                         |
      | URL Prefix 0          | http://www.shorter.gov                  |
    And I press "Update"
    Then I should see "Name can't be blank"

    When I am on noaa.gov's search page
    And I fill in "query" with "hurricane"
    And I press "Search"
    Then I should see "My Edited Collection" in the left column

    When I go to the affiliate admin page with "noaa.gov" selected
    And I follow "Collections"
    And I press "Delete"
    Then I should see "Collections entry successfully deleted."
    And I should see "Site Noaa Site has no Collections"

  Scenario: A user searching on the affiliate site with document collections in place