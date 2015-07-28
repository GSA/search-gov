module Searches
  class CustomLinkRenderer < WillPaginate::ActionView::LinkRenderer
    protected

    def windowed_page_numbers
      inner_window, outer_window = @options[:inner_window].to_i, @options[:outer_window].to_i
      window_from = current_page - inner_window
      window_to = current_page + inner_window
      
      # adjust lower or upper limit if other is out of bounds
      if window_to > total_pages
        window_from -= window_to - total_pages
        window_to = total_pages
      end
      if window_from < 1
        window_to += 1 - window_from
        window_from = 1
        window_to = total_pages if window_to > total_pages
      end
      
      # these are always visible
      middle = window_from..window_to

      # left window
      if outer_window + 3 < middle.first # there's a gap
        left = (1..(outer_window + 1)).to_a
        left << :gap
      else # runs into visible pages
        left = 1...middle.first
      end
      
      left.to_a + middle.to_a
    end

    def page_number(page)
      unless page == current_page
        link(page, page, :rel => rel_value(page), :class => 'pagination-numbered-link')
      else
        tag(:em, page, :class => 'current')
      end
    end

  end
end