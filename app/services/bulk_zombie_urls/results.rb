module BulkZombieUrls
  class Results
    attr_accessor :ok_count, :updated, :error_count, :file_name

    def initialize(filename)
      @file_name = filename
      @ok_count = 0
      @updated = 0
      @error_count = 0
      @errors = Hash.new { |hash, key| hash[key] = [] }
    end

    def delete_ok
      @ok_count += 1
    end

    def add_error(error_message, key)
      @error_count += 1
      @errors[key] << error_message
    end

    def errors
      @errors
    end

    def total_count
      ok_count + error_count
    end

    def urls_with(id)
      @errors[id]
    end
  end
end
