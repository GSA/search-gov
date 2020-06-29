# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  extend ResqueJobStats
end
