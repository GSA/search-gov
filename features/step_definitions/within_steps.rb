{
  'in the header' => '.zheader',
  'in the footer' => '.outer-footer'
}.
  each do |within, selector|
    Then /^(.+) #{within}$/ do |step|
      within(selector) do
        Then step
      end
    end
  end
