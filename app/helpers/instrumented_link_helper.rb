# frozen_string_literal: true

module InstrumentedLinkHelper
  def instrumented_link_to(title, path, count, name)
    link_to title, path, remote: true, data: { params: { index: count } }, id: "new-#{name}-trigger"
  end
end
