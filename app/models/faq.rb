class Faq < ActiveRecord::Base
  validates_presence_of :url, :question, :answer, :ranking, :locale
  validates_numericality_of :ranking, :only_integer => true

  searchable do
    text :question
    integer :ranking
    string :locale
  end

  class << self

    def search_for(query, locale = I18n.default_locale.to_s, per_page = 3)
      Faq.search do
        fulltext query do
          highlight :question, { :fragment_size => 255, :max_snippets => 1, :merge_continuous_fragments => true }
        end
        with(:locale).equal_to(locale)
        paginate :page => 1, :per_page => per_page
      end rescue nil
    end


    def faq_config(locale)


      config_yml = ::Rails.root.join("config", "faq.yml")


      @faq_config = if File.exist?(config_yml)
                      faq_config = YAML.load(File.read(config_yml))[::Rails.env]
                    else
                      { }
                    end

      fconf = {}
      @faq_config.each do |name, value|
        fconf[name.to_sym] = if value.kind_of?(Hash)
                        value[locale]
                      else
                        value
                      end
      end
      return fconf

    end


    def cached_file_path( name )
      tmp_dir = ::Rails.root.join("tmp", "faq")
      FileUtils.mkdir( tmp_dir ) unless File.exist?(tmp_dir)
      return tmp_dir.join( name )
    end


    def grab_latest_file(locale)

      fconf = faq_config(locale)
      new_file_path = nil
      return nil unless fconf.key?(:protocol)

      case fconf[:protocol]

      when 'sftp' :

        Net::SFTP.start(fconf[:host], fconf[:username], :password => fconf[:password]) do |sftp|
          matching_file_names = []
          file_name_pattern = Regexp.compile(fconf[:file_name_pattern])
          sftp.dir.foreach(fconf[:dir_path]) do |entry| 
            entry_name = entry.name
            matching_file_names << entry_name unless file_name_pattern.match(entry_name).nil?
          end

          unless matching_file_names.empty?
            latest_file_name = matching_file_names.sort.last
            raise "bad faq file path name: #{latest_file_name}" unless latest_file_name =~ /[a-z0-9_]+\.xml/
            cached_file = cached_file_path(latest_file_name)
            unless File.exist?(cached_file)
              inc_file_path = cached_file.to_s + "_inc"
              sftp.download!("#{fconf[:dir_path]}/#{latest_file_name}", inc_file_path)
              File.rename(inc_file_path, cached_file)
              new_file_path = cached_file
            end
          end
        end

      else

        raise "unsupported faq fetch protocol: #{fconf[:protocol]}"

      end

      return new_file_path

    end


  end

end
