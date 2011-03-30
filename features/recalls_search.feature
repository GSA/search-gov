Feature: Recalls search
  In order to get government-related recalls
  As a site visitor
  I want to search for recalls
  
  Scenario: Recalls Search
    Given I am on the recalls search page
    When I fill in "query" with "strollers"
    And I press "Search"
    Then I should be on the recalls search page
    And I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see "strollers"
    
  Scenario: A nonsense search
    Given I am on the recalls search page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search from the recalls home page
    Given I am on the recalls landing page
    When I submit the search form
    Then I should be on the recalls landing page

  Scenario: Doing a blank search from the recalls SERP
    Given I am on the recalls search page
    When I submit the search form
    Then I should be on the recalls landing page

  Scenario: The Recalls landing page
    Given the following Product Recalls exist:
    |recall_number|manufacturer                   |type    |product                                                     |hazard        |country             |recalled_days_ago|
    |10155        |Graco                          |Stroller|Graco E-Z Roller baby strollers, Graco Hard-to-Roll stroller|Entrapment    |Canada              |15               |
    |10157        |Hasbro                         |Stroller|Hasbro Window Stroller                                      |Defenestration|USA                 |18               |
    |10156        |Graco, Walmart, Martha Stewart |Bed     |Graco Cozy Glow-in-the-Dark Classic Toddler Beds            |Vomiting      |USA, Vietnam, China |25               |
    |10150        |Graco                          |Stroller|Graco Neck Restraint                                        |Decapitation  |Canada              |35               |
    Given I am on the homepage
    And I follow "Recalls"
    Then I should be on the recalls landing page
    And I should not see "ROBOTS" meta tag
    And I should see "Latest Recalls"
    And I should see "Graco E-Z Roller baby strollers, Graco Hard-to-Roll stroller"
    And I should see "Hasbro Window Stroller"
    And I should see "Graco Cozy Glow-in-the-Dark Classic Toddler Beds"
    And I should see "Graco Neck Restraint"


