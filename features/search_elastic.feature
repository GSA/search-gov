Feature: SearchElastic engine search
  In order to get results directly form elasticsearch
  As a site visitor to a site using the SearchElastic search engine
  I want to be able to search an site using the SearchElastic search engine

  Background:
    Given the following SearchElastic Affiliates exist:
      | display_name | name  | contact_email  | domains      |
      | NASA         | nasa  | admin@nasa.gov | www.nasa.gov |
    And there are urls indexed for nasa

  @javascript
  Scenario: Search on an affiliate using the SearchElastic search engine
    When I am on nasa's search page
    And I search for "hubble" in the redesigned search page
    Then I should see "NASA Extends Hubble Operations Contract"
