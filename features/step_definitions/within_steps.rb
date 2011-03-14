{
  'in the header' => '.header',
  'in the affiliate program dropdown menu' => '.affiliate-li',
  'in the api dropdown menu' => '.api-li',
  'in the main navigation bar' => '.wrap-navglobal',
  'in the breadcrumbs' => '.breadcrumbs',
  'in the footer' => '.outer-footer'
}.
  each do |within, selector|
    Then /^(.+) #{within}$/ do |step|
      within(selector) do
        Then step
      end
    end
  end

{
  'in the new user form' => '#new_user',
  'in the login form' => '#new_user_session'
}.
  each do |within, selector|
    When /^I fill in the following #{within}:$/ do |fields|
      within(selector) do
        fields.rows_hash.each do |name, value|
          When %{I fill in "#{name}" with "#{value}"}
        end
      end
    end
  end
