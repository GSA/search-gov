class MedTopic < ActiveRecord::Base
  MAX_MED_TOPIC_SUMMARY_LENGTH = 200
  MEDLINE_BASE_URL = 'https://medlineplus.gov/'
  MEDLINE_BASE_VOCAB_URL = "#{MEDLINE_BASE_URL}xml/"

  validates_presence_of :medline_tid, :medline_title, :locale
  has_many :synonyms, :class_name => 'MedSynonym', :foreign_key => :topic_id, :dependent => :destroy
  has_many :med_related_topics, dependent: :destroy, order: :title
  has_many :med_sites, dependent: :destroy, order: :title

  def self.download_medline_xml(date)
    xml_file_name = medline_xml_file_name(date)
    xml_file_path = medline_xml_file_path(xml_file_name)
    return xml_file_path if File.exist?(xml_file_path.to_s)

    staging_medline_xml_path = "#{xml_file_path}-staging"
    medline_xml_url = "#{MEDLINE_BASE_VOCAB_URL}#{xml_file_name}"

    File.open(staging_medline_xml_path, 'w+', :encoding => Encoding::BINARY) do |staging_file|
      Net::HTTP.get_response(URI.parse(medline_xml_url)) do |response|
        response.read_body do |fragment|
          staging_file.write(fragment)
        end
      end
    end
    File.rename(staging_medline_xml_path, xml_file_path)
    xml_file_path
  end

  def self.medline_xml_file_name(date = nil)
    effective_date = medline_publish_date(date || Date.current)
    "mplus_topics_#{effective_date.strftime("%Y-%m-%d")}.xml"
  end

  def self.medline_publish_date(date)
    case date.wday
    when 0 then
      date.advance(:days => -1)
    when 1 then
      date.advance(:days => -2)
    else
      date
    end
  end

  def self.medline_xml_file_path(name)
    tmp_dir = Rails.root.join('tmp', 'medline')
    FileUtils.mkdir_p(tmp_dir.to_s)
    File.join(tmp_dir, name)
  end

  def self.process_medline_xml(file_path)
    existing_topic_ids = MedTopic.select(:id).collect(&:id)
    File.open(file_path) do |medline_file|
      doc = Nokogiri::XML(medline_file)
      transaction do
        updated_topic_ids = []
        doc.xpath('/health-topics/health-topic').each do |element|
          topic = process_health_topic(element)
          updated_topic_ids << topic.id
        end
        obsolete_topic_ids = existing_topic_ids - updated_topic_ids
        MedTopic.destroy_all(:id => obsolete_topic_ids)
      end
    end
  end

  def self.process_health_topic(element)
    topic = MedTopic.where(:medline_tid => element.attr(:id)).first_or_initialize
    topic.medline_title = element.attr(:title).to_s.strip
    topic.medline_url = element.attr(:url).to_s.strip
    topic.locale = case element.attr(:language).to_s.strip
                   when 'Spanish' then :es
                   else :en
                   end
    topic.summary_html = element.xpath('full-summary').inner_text

    synonyms = []
    element.xpath('./also-called').each do |also_called|
      if topic.new_record?
        topic.synonyms.build(:medline_title => also_called.inner_text)
      else
        synonyms << topic.synonyms.where(:medline_title => also_called.inner_text).first_or_create!
      end
    end
    topic.synonyms = synonyms unless topic.new_record?

    related_topics = []
    element.xpath('./related-topic').each do |rt|
      related_medline_tid = rt.attr(:id).to_s.strip
      title = rt.inner_text.to_s.strip
      url = rt.attr(:url).to_s.strip
      if topic.new_record?
        topic.med_related_topics.build(:related_medline_tid => related_medline_tid,
                                       :title => title,
                                       :url => url)
      else
        related_topic = topic.med_related_topics.
            where(:related_medline_tid => related_medline_tid).
            first_or_initialize
        related_topic.title = title
        related_topic.url = url
        related_topic.save!
        related_topics << related_topic
      end
    end
    topic.med_related_topics = related_topics unless topic.new_record?

    sites = []
    element.xpath('./site').each do |site_element|
      next unless is_clinical_trial_site?(site_element)
      title = sanitize_clinical_trial_title(site_element.attr(:title))
      url = site_element.attr(:url).to_s.strip
      if topic.new_record?
        topic.med_sites.build(:title => title, :url => url)
      else
        site = topic.med_sites.where(:title => title, :url => url).first_or_create!
        sites << site
      end
    end
    topic.med_sites = sites unless topic.new_record?

    topic.save!
    topic
  end

  def self.search_for(title, locale = 'en')
    stripped_title = title.to_s.strip
    matched_topic = where(:medline_title => stripped_title, :locale => locale).first
    unless matched_topic
      matched_synonym = MedSynonym.where(:medline_title => stripped_title).find do |synonym|
        synonym.topic.locale == locale
      end
      matched_topic = matched_synonym.topic if matched_synonym
    end
    matched_topic
  end

  def truncated_summary
    sentences = Sanitize.clean(summary_html).gsub(/[[:space:]]/, ' ').squish.split(/\.\s*/)
    summary = ''

    sentences.slice(0,3).each do |sentence|
      break if (summary.length + sentence.length + 1) > MAX_MED_TOPIC_SUMMARY_LENGTH
      summary << sentence << '. '
    end
    summary.squish
  end

  private
  def self.is_clinical_trial_site?(site_element)
    title = site_element.attr(:title).to_s.strip
    title.starts_with?('ClinicalTrials.gov:')
  end

  def self.sanitize_clinical_trial_title(title)
    title.to_s.split(':').last.strip
  end
end
