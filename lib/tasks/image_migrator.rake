namespace :usasearch do
  desc "Migrate Images from Rackspace to AWS"
  task :migrate_images, [:table,:ids] => [:environment] do |_t, args|

    @args = args
    check_args

    @table = args[:table]
    @ids = args[:ids].split.map(&:to_i) if args[:ids]
    @klass = @table.classify.constantize
    @rackspace_images = rackspace_images
    @failures = []

    migrate
  end

  private

  def check_args
    unless ['featured_collections', 'affiliates'].include? @args[:table]
      abort('Table must be featured_collections or affiliates.')
    end

    if @args[:ids] && !(/\A(\d+ ?)+\z/ === @args[:ids])
      abort('Ids must be a space-delimited list.')
    end
  end

  def migrate
    abort('No records found to update.') if records.count == 0
    open_verification_file
    records.find_each(batch_size: 10) { |record| migrate_images(record) }
    report_failures if @failures.present?
  ensure
    close_verification_file if @file && !@file.closed?
  end

  def records
    @ids.present? ? @klass.where(id: @ids) : @klass.where(conditions)
  end

  def migrate_images(record)
    begin
      @rackspace_images.each { |image| migrate_image(record,image) if record.send(image).present? }
      record.save!
      puts "Migrated images for #{record.class} #{record.id}".green
    rescue StandardError => error
      log_error(record, error)
    end
  end

  def migrate_image(record,image)
    record.send("aws_#{image}=", record.send(image))
    @file.puts "<tr><td>#{record.id}</td>
                <td><img src='#{record.send(image).url}' style='max-width:200px'></td>
                <td><img src='#{record.send("aws_#{image}").url})' style='max-width:200px'></td></tr>"
  end

  def report_failures
    puts "Failed to update images for #{@table}:\n#{@failures.join("\n")}".red
  end

  def log_error(record, error)
    @failures << record.id
    puts "Unable to migrate images for #{record.class} #{record.id}: #{error}\n#{error.backtrace.first}".red
  end

  def conditions
    @rackspace_images.map do | image|
      "(#{image}_file_name is not null
       AND (aws_#{image}_updated_at is null
            OR aws_#{image}_updated_at < #{image}_updated_at))"
    end.join(' OR ')
  end

  def rackspace_images
    @klass.attachment_definitions.select{|_k,v| v[:storage] == :cloud_files }.keys
  end

  def open_verification_file
    @file = File.open("tmp/image_verification_#{Time.now.to_i}.html", 'w')
    @file.puts "<!DOCTYPE html>\n<html>\n<body>\n<table>
                <tr><th>ID</th><th>Rackspace Image</th><th>AWS Image</th></tr>"
  end

  def close_verification_file
    @file.puts "</body>\n</html>"
    @file.close
    puts "Verify migrated images: #{@file.path}"
  end
end
