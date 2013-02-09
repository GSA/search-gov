Feature: Mobile Search
  In order to get government-related information on my mobile device
  As a mobile device user
  I want to be able to search with a streamlined interface

  Background:
    Given I am using a mobile device

  Scenario: Visiting the home page with a mobile device
    Given I am on the homepage
    Then I should see "INDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see a link to "Visit Our Blog" with url for "http://blog.usa.gov"
    And I should see a link to "Text/SMS Services" with url for "http://search.usa.gov/usa/sms"
    And I should see a link to "Español" with url for "http://m.gobiernousa.gov"
    And I should see a link to "USA.gov Full Site" with url for "http://www.usa.gov/?mobile-opt-out=true"

  Scenario: Visiting the home page with a tablet (e.g. iPad) device
    Given I am using a tablet device
    And I am on the homepage
    Then I should not see "ROBOTS" meta tag
    And I should not see "Visit Our Blog"
    And I should not see "Text/SMS Services"
    And I should not see "Español"
    And I should not see "USA.gov Full Site"

  Scenario: Visiting the Spanish home page with a mobile device
    Given I am on the Spanish homepage
    When I follow "Search in English"
    Then I should be on the homepage

  Scenario: Toggling full mode
    Given I am on the search page
    When I follow "Classic"
    Then I should be on the search page

  Scenario: Going to mobile mode from Spanish web homepage
    Given I am using a desktop device
    And I am on the Spanish homepage
    Then I should see a link to "Móvil" with url for "http://m.gobiernousa.gov"

  Scenario: A search on the mobile home page
    Given the following Affiliates exist:
      | display_name | name   | contact_email | contact_name |
      | USA.gov      | usagov | aff@usa.gov   | John Bar     |
    And I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see "USA.gov Mobile"
    And I should see "Social Security"
    And I should see 3 search results
    When I follow "Next"
    Then I should see "USA.gov Mobile"

  Scenario: A search on the home page from a tablet
    Given I am using a tablet device
    And I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should not see "Classic | Mobile"

  Scenario: Visiting the Spanish mobile SERP
    Given I am on the Spanish homepage
    When I fill in "query" with "educación"
    And I submit the search form
    Then I should be on the search page
    And I should see "educación"
    When I follow "Siguiente"
    Then I should see "Gobierno.USA.gov Móvil"

  Scenario: An advanced search on the mobile home page
    When I am on the advanced search page
    Then I should see "Use the options on this page to create a very specific search"

  Scenario: Emailing from the home page
    Given I am on the homepage
    When I follow "E-mail us"
    Then I should be on the mobile contact form page
    And I should see "Contact your Government"
    And I should see "Email"
    And I should see "Message"
    When I fill in "Email" with "mobileuser@usa.gov"
    And I fill in "Message" with "I love your site!"
    And I press "Submit"
    Then I should be on the mobile contact form page
    And I should see "Thank you for contacting USA.gov."
    And "musa.gov@mail.fedinfo.gov" should receive an email
    When I open the email
    Then I should see "USA.gov Mobile Inquiry" in the email subject
    And I should see "[FORMGEN]" in the email body

    When I go to the mobile contact form page
    And I follow "USASearch Home"
    Then I should be on the homepage

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

  Scenario: Emailing from the Spanish home page
    Given I am on the Spanish homepage
    When I follow "Envíanos un e-mail"
    Then I should be on the mobile contact form page
    And I should see "Envíenos un e-mail"
    And I should see "Su e-mail"
    And I should see "Mensaje"
    And I fill in "Su e-mail" with "spanishmobileuser@usa.gov"
    And I fill in "Mensaje" with "I love your site!"
    And I press "Enviar"
    Then I should be on the mobile contact form page
    And I should see "Gracias por contactar a GobiernoUSA.gov. Le responderemos en dos días hábiles."
    And "mgobiernousa.gov@mail.fedinfo.gov" should receive an email
    When I open the email
    Then I should see "GobiernoUSA.gov Mobile Inquiry" in the email subject
    And I should see "[FORMGEN]" in the email body

    When I go to the Spanish mobile contact form page
    Then I should see an image link to "USASearch Home" with url for "http://m.gobiernousa.gov"

  Scenario: Emailing from the Spanish home page with problem
    Given I am on the Spanish homepage
    When I follow "Envíanos un e-mail"
    And I fill in "Su e-mail" with " "
    And I fill in "Mensaje" with " "
    And I press "Enviar"
    Then I should be on the mobile contact form page
    And I should see "Faltan datos requeridos"
    When I fill in "Su e-mail" with "invalid email"
    And I fill in "Mensaje" with "I love your site"
    And I press "Enviar"
    Then I should be on the mobile contact form page
    And I should see "Este e-mail no es válido"
    And the "Su e-mail" field should contain "invalid email"
    And the "Mensaje" field should contain "I love your site"
