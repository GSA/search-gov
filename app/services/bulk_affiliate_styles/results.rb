# frozen_string_literal: true

class BulkAffiliateStyles::Results
  attr_accessor :affiliates, :ok_count, :updated, :error_count, :file_name

  def initialize(filename)
    @file_name = filename
    @ok_count = 0
    @updated = 0
    @error_count = 0
    @affiliates = Set.new
    @errors = Hash.new { |hash, key| hash[key] = [] }
  end

  def add_ok(affiliate_id)
    self.ok_count += 1
    affiliates << affiliate_id
  end

  def add_error(error_message, affiliate_id)
    self.error_count += 1
    @errors[affiliate_id] = error_message
  end

  def total_count
    ok_count + error_count
  end

  def affiliates_with(id)
    @errors[id]
  end
end
