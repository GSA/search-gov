{
  'in the header' => '.zheader'
}.
  each do |within, selector|
    Then /^(.+) #{within}$/ do |step|
      within(selector) do
        Then step
      end
    end
  end
