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
    Then I should see "Contact your Government"

  Scenario: Toggling full mode
    Given I am on the search page
    When I follow "Classic"
    Then I should be on the search page
    And I should see "Mobile"

  Scenario: Toggling back to mobile mode
    Given I am on the search page
    When I follow "Classic"
    And I follow "Mobile"
    Then I should be on the search page
    And I should see "View site in:"
    
  Scenario: Going to mobile mode from Spanish web homepage
    Given I am using a desktop device
    And I am on the Spanish homepage
    Then I should see "Móvil"
    When I follow "Móvil"
    Then I should be on the search page
    And I should see "Por favor, introduzca los términos de búsqueda"
    And I should see "Versión: Web | Móvil"

  Scenario: Using mobile mode with a browser not identified as mobile
    Given I am using a desktop device
    And I am on the homepage
    When I follow "Mobile"
    Then I should see "Contact your Government"

  Scenario: A search on the mobile home page
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should see "Social Security"
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
    And I should see "Graco E-Z Roller baby strollers, Graco Hard-to-Roll stroller"
    And I should see "Graco Cozy Glow-in-the-Dark Classic Toddler Beds"
    And I should not see "Hasbro Window Stroller"
    And I should not see "Graco Neck Restraint"

  Scenario: A search with auto results containing recent recalls
    Given the following Auto Recalls exist:
    |recall_number|manufacturer              |component_description                                   |recalled_days_ago|
    |10155        |TOYOTA, TOYOTA            |FRONT BRAKE PADS, STEERING WHEEL                        |15               |
    |10157        |TOYOTA                    |REAR-VIEW MIRROR                                        |18               |
    |10156        |HONDA, INFINITI, PORSCHE  |BRAKE PAD ASSEMBLY,BRAKE PAD ASSEMBLY,BRAKE PAD ASSEMBLY|25               |
    |10150        |TOYOTA                    |OLD BRAKE PADS                                          |35               |
    And I am on the homepage
    When I fill in "query" with "brake pad recall"
    And I submit the search form
    Then I should be on the search page
    And I should see "FRONT BRAKE PADS, STEERING WHEEL FROM TOYOTA"
    And I should see "BRAKE PAD ASSEMBLY FROM HONDA, INFINITI, PORSCHE"
    And I should not see "REAR-VIEW MIRROR"
    And I should not see "OLD BRAKE PADS"

  Scenario: A search with results containing food recalls
    Given the following Food Recalls exist:
    |recalled_days_ago|summary                                      |description                                              | url                                                                     |
    |1                |Stay Puft recalls marshmallows               |These are just too creepy for kids                       | http://www.fda.gov/Safety/Recalls/ucm207251.htm                         |
    |18               |The Fizz recalls Screw-on Ice Cream Float Cup|The cup is reusable, but not dishwasher safe.            | http://www.fda.gov/Safety/Recalls/ucm207252.htm                         |
    |25               |Curry recalled due to unlisted allergens     |It contains the ghost curry as well as raw marshmallows  | http://www.fsis.usda.gov/News_&_Events/Recall_061_2009_Release/index.asp|
    |35               |Old Marshmallow Recall news                  |These were recalled a very long time ago due to staleness| http://www.fsis.usda.gov/News_&_Events/Recall_062_2009_Release/index.asp|
    And I am on the homepage
    When I fill in "query" with "recall of marshmallows"
    And I submit the search form
    Then I should be on the search page
    And I should see "Stay Puft recalls marshmallows"
    And I should see "Curry recalled due to unlisted allergens"
    And I should not see "The Fizz recalls Screw-on Ice Cream Float Cup"
    And I should not see "Old Marshmallow Recall news"

  Scenario: Emailing from the home page
    Given I am on the homepage
    Then I should see "E-mail Us"
    When I follow "E-mail Us"
    Then I should be on the mobile contact form page
    And I should see "Contact your Government"
    And I should see "Email"
    And I should see "Message"
    And I fill in "Email" with "mobileuser@usa.gov"
    And I fill in "Message" with "I love your site!"
    And I press "Submit"
    Then I should be on the mobile contact form page
    And I should see "Thank you for contacting USA.gov. We will respond to you within two business days"
    And "musa.gov@mail.fedinfo.gov" should receive an email

  Scenario: User does not provide some information for contact form
    Given I am on the mobile contact form page
    And I fill in "Email" with "mobileuser@usa.gov"
    And I press "Submit"
    Then I should see "Missing required fields (*)"
    And the "Email" field should contain "mobileuser@usa.gov"

    When I am on the mobile contact form page
    And I fill in "Message" with "I love your site!"
    And I press "Submit"
    Then I should see "Missing required fields (*)"
    And the "Message" field should contain "I love your site!"

    When I am on the mobile contact form page
    And I fill in "Email" with "bad email"
    And I fill in "Message" with "message"
    And I press "Submit"
    Then I should see "Email address is not valid"
    And the "Email" field should contain "bad email"
    And the "Message" field should contain "message"

  Scenario: A mobile image search
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    When I follow "Images"
    Then I should be on the image search page
    And I should see 30 image results
    And I should see "Next"

    Given I am on the homepage
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."
    When I follow "Images"
    Then I should be on the image search page
    And I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

    Given I am on the homepage
    When I submit the search form
    Then I should be on the search page
    When I follow "Images"
    Then I should be on the image search page
    And I should see "Please enter search term(s)"



