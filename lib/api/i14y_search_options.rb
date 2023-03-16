# frozen_string_literal: true

class Api::I14ySearchOptions < Api::SearchOptions
  attr_accessor :audience,
                :content_type,
                :created_since_date,
                :created_until_date,
                :mime_type,
                :searchgov_custom1,
                :searchgov_custom2,
                :searchgov_custom3,
                :since_date,
                :sort_by,
                :tags,
                :until_date

  # SRCH-3922: Very basic first-pass date validation, not tackling localization at this time
  # rubocop:disable Rails/I18nLocaleTexts
  validates :created_since_date, :created_until_date, :since_date, :until_date,
            exclusion: { in: ['invalid date'],
                         message: 'must be in YYYY-mm-dd format' }
  # rubocop:enable Rails/I18nLocaleTexts

  # SRCH-3615: Disabling cop temporarily as facets work is ongoing and will continue to involve
  # modifications to this method.
  # rubocop:disable Metrics/AbcSize
  def initialize(params = {})
    super
    self.audience = params[:audience]
    self.content_type = params[:content_type]
    self.mime_type = params[:mime_type]
    self.searchgov_custom1 = params[:searchgov_custom1]
    self.searchgov_custom2 = params[:searchgov_custom2]
    self.searchgov_custom3 = params[:searchgov_custom3]
    self.sort_by = params[:sort_by]
    self.tags = params[:tags]
    initialize_date_fields(params)
  end
  # rubocop:enable Metrics/AbcSize

  def initialize_date_fields(params)
    self.created_since_date = modify_date_string(params[:created_since]) if params[:created_since]
    self.created_until_date = modify_date_string(params[:created_until]) if params[:created_until]
    self.since_date = modify_date_string(params[:updated_since]) if params[:updated_since]
    self.until_date = modify_date_string(params[:updated_until]) if params[:updated_until]
  end

  def attributes
    super.merge({ audience: audience,
                  content_type: content_type,
                  created_since_date: created_since_date,
                  created_until_date: created_until_date,
                  mime_type: mime_type,
                  searchgov_custom1: searchgov_custom1,
                  searchgov_custom2: searchgov_custom2,
                  searchgov_custom3: searchgov_custom3,
                  since_date: since_date,
                  sort_by: sort_by,
                  tags: tags,
                  until_date: until_date })
  end

  private

  def modify_date_string(date)
    Date.parse(date).strftime(I18n.t(:cdr_format))
  rescue
    'invalid date'
  end
end
