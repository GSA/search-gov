module Fetchable
  extend ActiveSupport::Concern

  OK_STATUS = "OK"
  UNSUPPORTED_EXTENSION = "URL extension is not one we index"
  BLACKLISTED_EXTENSIONS = %w{wmv mov css csv gif htc ico jpeg jpg js json mp3 png rss swf txt wsdl xml zip gz z bz2 tgz jar tar m4v}

  included do
    before_validation :normalize_url
    validates_length_of :url, maximum: 2000
    validates_presence_of :url
    validates_url :url, allow_blank: true
    validates_inclusion_of :doctype, in: self.doctypes, allow_nil: true #FIXME

    extend ClassMethods
  end


  module ClassMethods
    def supported_content_types
      mime_types.keys.freeze
    end

    def doctypes
      mime_types.values.uniq.freeze
    end

    def mime_types
      {
        'text/html' => 'html',
        'application/msword' => 'word',
        'application/pdf' => 'pdf',
        'application/vnd.ms-excel' => 'excel',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'word',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'excel',
      }.freeze
    end
  end

  private

  def self_url
    @self_url ||= URI.parse(self.url) rescue nil
  end

  def normalize_url
    return if self.url.blank?
    ensure_prefix_on_url
    downcase_scheme_and_host_and_remove_anchor_tags
  end

  def ensure_prefix_on_url
    self.url = "https://#{self.url}" unless self.url.blank? or self.url =~ %r{^https?://}i
    @self_url = nil
  end

  def downcase_scheme_and_host_and_remove_anchor_tags
    if self_url
      scheme = self_url.scheme.downcase
      host = self_url.host.downcase
      request = self_url.request_uri.gsub(/\/+/, '/')
      self.url = "#{scheme}://#{host}#{request}"
      @self_url = nil
    end
  end

  def url_extension
    Addressable::URI.parse(url).extname.downcase.from(1)
  end


end
