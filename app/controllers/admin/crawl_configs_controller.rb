class Admin::CrawlConfigsController < Admin::AdminController
  active_scaffold :crawl_config do |config|
    config.label = 'Crawl Configs'
    config.columns = [
      :name,
      :active,
      :allowed_domains,
      :starting_urls,
      :sitemap_urls,
      :deny_paths,
      :depth_limit,
      :sitemap_check_hours,
      :allow_query_string,
      :handle_javascript,
      :schedule,
      :output_target,
      :created_at,
      :updated_at
    ]

    # Form configuration
    config.columns[:active].form_ui = :checkbox
    config.columns[:active].description = 'Enable or disable this crawl configuration'

    config.columns[:allowed_domains].form_ui = :textarea
    config.columns[:allowed_domains].options = { cols: 60, rows: 5 }
    config.columns[:allowed_domains].description = 'Enter one domain per line (e.g., example.gov)'

    config.columns[:starting_urls].form_ui = :textarea
    config.columns[:starting_urls].options = { cols: 60, rows: 5 }
    config.columns[:starting_urls].description = 'Enter one URL per line'

    config.columns[:sitemap_urls].form_ui = :textarea
    config.columns[:sitemap_urls].options = { cols: 60, rows: 3 }
    config.columns[:sitemap_urls].description = 'Optional: Enter one sitemap URL per line'

    config.columns[:deny_paths].form_ui = :textarea
    config.columns[:deny_paths].options = { cols: 60, rows: 3 }
    config.columns[:deny_paths].description = 'Optional: Enter one path pattern per line to exclude'

    config.columns[:depth_limit].description = 'Maximum crawl depth (integer)'
    config.columns[:sitemap_check_hours].description = 'Optional: Hours between sitemap checks (integer)'
    config.columns[:allow_query_string].form_ui = :checkbox
    config.columns[:allow_query_string].description = 'Allow URLs with query strings'
    config.columns[:handle_javascript].form_ui = :checkbox
    config.columns[:handle_javascript].description = 'Enable JavaScript rendering during crawl'
    config.columns[:schedule].description = 'Cron expression (e.g., "0 0 * * *" for daily at midnight)'
    config.columns[:output_target].form_ui = :select

    # List configuration
    config.list.sorting = { name: :asc }
    config.list.columns = [:name, :allowed_domains, :starting_urls, :sitemap_urls, :depth_limit, :schedule, :output_target]

    # Actions
    config.actions.exclude :search
    config.actions.add :field_search, :export
    config.field_search.columns = [:name, :allowed_domains, :output_target]

    config.export.columns = config.columns
  end

  # Override to handle array inputs from textarea
  def before_create_save(record)
    normalize_array_fields(record)
  end

  def before_update_save(record)
    normalize_array_fields(record)
  end

  private

  def normalize_array_fields(record)
    # Convert textarea input to arrays
    [:allowed_domains, :starting_urls, :sitemap_urls, :deny_paths].each do |field|
      value = params[:record][field]
      if value.is_a?(String)
        record.send("#{field}=", value.split("\n").map(&:strip).reject(&:blank?))
      end
    end
  end
end
