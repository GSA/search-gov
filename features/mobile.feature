Feature: Mobile Search
  In order to get government-related information on my mobile device
  As a mobile device user
  I want to be able to search with a streamlined interface

  Background:
    Given I am using a mobile device

  Scenario: Visiting the home page from a desktop browser
    Given I am using a desktop device
    And I am on the homepage
    Then I should see "Mobile"

  Scenario: Visiting the home page with a mobile device
    Given I am on the homepage
    Then I should see "Full Site"

  Scenario: Toggling full mode
    Given I am on the homepage
    When I follow "Full Site"
    Then I should be on the homepage
    And I should see "Mobile"

  Scenario: Toggling back to mobile mode
    Given I am on the homepage
    When I follow "Full Site"
    And I follow "Mobile"
    Then I should be on the homepage
    And I should see "Full Site"

  Scenario: Using mobile mode with a brower not identified as mobile
    Given I am using a desktop device
    And I am on the homepage
    When I follow "Mobile"
    Then I should see "Full Site"

  Scenario: A search on the mobile home page
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should see "social security"
    And I should see 3 search results

  Scenario: An advanced search on the mobile home page
    When I am on the advanced search page
    Then I should see "Use the options on this page to create a very specific search"

  Scenario: A search with results containing recalls on multiple days
    Given the following Product Recalls exist:
    |recall_number|manufacturer                   |type    |product                                                     |hazard        |country             |recalled_days_ago|
    |10155        |Graco                          |Stroller|Graco E-Z Roller baby strollers, Graco Hard-to-Roll stroller|Entrapment    |Canada              |15               |
    |10157        |Hasbro                         |Stroller|Hasbro Window Stroller                                      |Defenestration|USA                 |18               |
    |10156        |Graco, Walmart, Martha Stewart |Bed     |Graco Cozy Glow-in-the-Dark Classic Toddler Beds            |Vomiting      |USA, Vietnam, China |25               |
    |10150        |Graco                          |Stroller|Graco Neck Restraint                                        |Decapitation  |Canada              |35               |
    And I am on the homepage
    When I fill in "query" with "graco recall"
    And I submit the search form
    Then I should be on the search page
    And in "recall1" I should see "Graco E-Z Roller baby strollers, Graco Hard-to-Roll stroller"
    And in "recall2" I should see "Graco Cozy Glow-in-the-Dark Classic Toddler Beds"
    And I should not see "Hasbro Window Stroller"
    And I should not see "Graco Neck Restraint"

  Scenario: A search with auto results containing recent recalls
    Given the following Auto Recalls exist:
    |recall_number|manufacturer              |component_description            |recalled_days_ago|
    |10155        |TOYOTA, TOYOTA                    |FRONT BRAKE PADS, STEERING WHEEL |15               |
    |10157        |TOYOTA                    |REAR-VIEW MIRROR                 |18               |
    |10156        |HONDA, INFINITI, PORSCHE  |BRAKE PAD ASSEMBLY,BRAKE PAD ASSEMBLY,BRAKE PAD ASSEMBLY               |25               |
    |10150        |TOYOTA                    |OLD BRAKE PADS                   |35               |
    And I am on the homepage
    When I fill in "query" with "brake pad recall"
    And I submit the search form
    Then I should be on the search page
    And in "recall1" I should see "FRONT BRAKE PADS, STEERING WHEEL FROM TOYOTA"
    And in "recall2" I should see "BRAKE PAD ASSEMBLY FROM HONDA, INFINITI, PORSCHE"
    And I should not see "REAR-VIEW MIRROR"
    And I should not see "OLD BRAKE PADS"
