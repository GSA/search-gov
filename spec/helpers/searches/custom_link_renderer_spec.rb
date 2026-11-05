# frozen_string_literal: true

describe Searches::CustomLinkRenderer do
  def render_pagination(page, total_pages)
    collection = WillPaginate::Collection.create(page, 1, total_pages) { |pager| pager.replace([]) }
    helper.will_paginate(collection,
                         renderer: described_class,
                         inner_window: 2,
                         outer_window: 0,
                         params: { controller: 'searches', action: 'index', affiliate: 'usagov' })
  end

  context 'when the current page is near the start' do
    subject(:html) { render_pagination(1, 3) }

    it 'renders the current page and numbered links without a gap' do
      expect(html).to have_selector('em.current', text: '1')
      expect(html).to have_link('3', class: 'pagination-numbered-link')
      expect(html).not_to have_selector('.gap')
    end
  end

  context 'when the current page is near the end' do
    subject(:html) { render_pagination(10, 10) }

    it 'renders the first page, a gap, and the last pages' do
      expect(html).to have_link('1', class: 'pagination-numbered-link')
      expect(html).to have_selector('.gap')
      expect(html).to have_link('6', class: 'pagination-numbered-link')
      expect(html).to have_selector('em.current', text: '10')
    end
  end
end
