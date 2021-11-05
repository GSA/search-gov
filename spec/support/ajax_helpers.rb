# frozen_string_literal: true

# In most cases, Capybara is smart enough to wait for page elements to be updated.
# This helper should only be used when absolutely necessary, such as for Active Scaffold pages.
def wait_for_ajax
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop do
      active = page.evaluate_script('jQuery.active')
      break if active == 0
    end
  end
end
