class MedTopic < ActiveRecord::Base
  MEDLINE_BASE_URL = "http://www.nlm.nih.gov/medlineplus/"
  MEDLINE_BASE_VOCAB_URL = MEDLINE_BASE_URL + "xml/vocabulary/"
  ACCEPTABLE_SYMMARY_URL_PREFIXES = [MEDLINE_BASE_URL]
  SATURDAY = 6
  DAYS_PER_WEEK = 7
  SUPPORTED_LOCALES = ["en", "es"]
  MESH_TITLE_SEPARATOR = ":"

  validates_presence_of :medline_tid, :medline_title, :locale
  has_many :synonyms, :class_name => "MedSynonym", :foreign_key => :topic_id, :dependent => :destroy
  has_many :group_relatees, :class_name => "MedTopicGroup", :foreign_key => :topic_id, :dependent => :destroy
  has_many :related_groups, :through => :group_relatees, :source => :group
  has_many :topic_relatees, :class_name => "MedTopicRelated", :foreign_key => :topic_id, :dependent => :destroy
  has_many :topic_relaters, :class_name => "MedTopicRelated", :foreign_key => :related_topic_id, :dependent => :destroy
  has_many :related_topics, :through => :topic_relatees, :source => :related_topic
  belongs_to :lang_mapped_topic, :class_name => "MedTopic"
  has_many :lang_mapping_topics, :class_name => "MedTopic", :foreign_key => :lang_mapped_topic_id, :dependent => :nullify

  @@fetch_count = 0

  def has_mesh_titles?
    not mesh_titles.empty?
  end

  def mesh_title_list
    mesh_titles.split(MESH_TITLE_SEPARATOR)
  end

  class << self

    def fetch_count
      @@fetch_count
    end

    def tmp_dir
      dir_path = ::Rails.root.join('tmp', 'medline')
      FileUtils.mkdir_p(dir_path) unless File.exist? dir_path
      dir_path
    end

    def saturday_on_or_before(date)
      day_of_week = date.wday
      most_recent_saturday = if day_of_week >= SATURDAY
        date - day_of_week + SATURDAY
      else
        date - day_of_week - DAYS_PER_WEEK + SATURDAY
      end
      most_recent_saturday
    end

    def xml_base_name_for_date(date = nil)
      effective_date = date.nil? ? saturday_on_or_before(Date.current) : date
      "mplus_vocab_#{effective_date.strftime("%Y-%m-%d")}"
    end

    def medline_xml_for_date(date = nil)
      vocab_xml_fns = "#{xml_base_name_for_date(date)}.xml"
      cached_data_path_incoming = cached_file_path("#{vocab_xml_fns}-incoming")
      cached_data_path = cached_file_path(vocab_xml_fns)
      return File.read(cached_data_path) if File.exist?(cached_data_path)

      vocab_xml_url = "#{MEDLINE_BASE_VOCAB_URL}#{vocab_xml_fns}"
      remote_data = Net::HTTP.get_response(URI.parse(vocab_xml_url)).body
      @@fetch_count += 1
      File.open(cached_data_path_incoming, "w") { |cached_data_file| cached_data_file.write(remote_data) }
      File.rename(cached_data_path_incoming, cached_data_path)
      remote_data
    end

    def cached_file_path(name)
      File.join(tmp_dir, name)
    end

    def dump_db_vocab
      topics = {}
      groups = {}
      all.each { |topic|
        lm_topic = topic.lang_mapped_topic
        topics[topic.medline_tid] = {
          :medline_title => topic.medline_title,
          :medline_url => topic.medline_url,
          :mesh_titles => topic.mesh_titles,
          :summary_html => topic.summary_html,
          :locale => topic.locale,
          :synonyms => [],
          :related_topics => [],
          :related_groups => [],
          :lang_map => if lm_topic.nil?
            nil
          else
            lm_topic.medline_tid
          end
        }
      }
      MedSynonym.all.each { |synonym|
        topics[synonym.topic.medline_tid][:synonyms] << synonym.medline_title unless synonym.topic.nil?
      }
      MedTopicRelated.all.each { |r|
        relator_medline_tid = r.topic.medline_tid
        related_medline_tid = r.related_topic.medline_tid
        if topics.key? relator_medline_tid
          topics[relator_medline_tid][:related_topics] << related_medline_tid
        end
      }

      MedGroup.all.each { |group|
        groups[group.medline_gid] = {} unless groups.key? group.medline_gid
        groups[group.medline_gid][group.locale] = {:medline_title => group.medline_title, :medline_url => group.medline_url}
      }

      MedTopicGroup.all.each { |vg|
        topic_medline_tid = vg.topic.medline_tid
        group_medline_gid = vg.group.medline_gid
        if topics.key? topic_medline_tid
          topics[topic_medline_tid][:related_groups] << group_medline_gid
        end
      }

      {:topics => topics, :groups => groups}
    end

    def delta_medline_vocab(have, want)

      have ||= {:topics => {}, :groups => {}}
      want ||= {:topics => {}, :groups => {}}

      wanted_topic_tids = (want[:topics]||{}).keys.sort
      wanted_group_tids = (want[:groups]||{}).keys.sort
      have_topic_tids = (have[:topics]||{}).keys.sort
      have_group_tids = (have[:groups]||{}).keys.sort

      todo = {}

      wanted_topic_tids.each { |topic_tid|
        wanted_topic_atts = want[:topics][topic_tid]
        have_topic_atts = have[:topics][topic_tid]
        if have_topic_atts.nil?
          (todo[:create_topic] ||= {})[{:medline_tid => topic_tid}] = wanted_topic_atts
        else
          changed_atts = {}
          wanted_topic_atts.each { |att_name, want_att_value|
            have_att_value = have_topic_atts[att_name]
            unless want_att_value === have_att_value
              changed_atts[att_name] = want_att_value
            end
          }
          unless changed_atts.empty?
            (todo[:update_topic] ||= {})[{:medline_tid => topic_tid}] = changed_atts
          end
        end
      }

      have_topic_tids.each { |topic_tid|
        unless want[:topics].key? topic_tid
          (todo[:delete_topic] ||= []) << {:medline_tid => topic_tid}
        end
      }

      wanted_group_tids.each { |group_gid|

        wanted_group_locale_map = want[:groups][group_gid]
        have_group_locale_map = have[:groups][group_gid]

        SUPPORTED_LOCALES.each { |locale|

          have_group_atts = if have_group_locale_map.nil?
            nil
          else
            have_group_locale_map[locale]
          end

          wanted_group_atts = wanted_group_locale_map[locale]

          if have_group_atts.nil?
            unless wanted_group_atts.nil?
              (todo[:create_group] ||= {})[{:medline_gid => group_gid, :locale => locale}] = wanted_group_atts
            end
          else
            if wanted_group_atts.nil?
              (todo[:delete_group] ||= []) << {:medline_gid => group_gid, :locale => locale}
            else
              changed_atts = {}
              wanted_group_atts.each { |att_name, want_att_value|
                have_att_value = have_group_atts[att_name]
                unless want_att_value === have_att_value
                  changed_atts[att_name] = want_att_value
                end
              }
              unless changed_atts.empty?
                (todo[:update_group] ||= {})[{:medline_gid => group_gid, :locale => locale}] = changed_atts
              end
            end

          end

        }
      }

      have_group_tids.each { |group_gid|
        wanted_group_locale_map = want[:groups][group_gid]
        if wanted_group_locale_map.nil?
          have_group_locale_map = have[:groups][group_gid]
          SUPPORTED_LOCALES.each { |locale|
            if have_group_locale_map.key? locale
              (todo[:delete_group] ||= []) << {:medline_gid => group_gid, :locale => locale}
            end
          }
        end
      }

      todo
    end

    def parse_medline_xml_meshheads(root)
      mesh_heads = []
      unless root.nil?
        root.xpath("MeshHeadingList").each do |mesh_headings_node|
          mesh_headings_node.xpath("MeshHeading/Descriptor/DescriptorName").each do |descr_name_node|
            descr_name = descr_name_node.text
            mesh_heads << descr_name.strip unless descr_name.nil? || descr_name.strip.empty? || descr_name.index(MESH_TITLE_SEPARATOR)
          end
        end
      end
      mesh_heads
    end

    def parse_medline_xml_vocab(xml)
      xml_doc = Nokogiri::XML(xml)
      topics = {}
      groups = {}
      xml_doc.xpath("//MedicalTopic").each { |topic_node|
        tid = topic_node.at_xpath('ID').text.to_i rescue nil
        lang = topic_node["langcode"] rescue "English"
        locale = {"Spanish" => 'es', "English" => 'en'}[lang] || 'en'
        medline_title = topic_node.at_xpath("MedicalTopicName").text rescue nil
        medline_url = topic_node.at_xpath("URL").text rescue nil
        lmtid = topic_node.at_xpath('LanguageMappedTopicID').text.to_i rescue nil
        summary = topic_node.at_xpath("FullSummary")
        linted_summary = if summary.nil?
          nil
        else
          lint_medline_topic_summary_html(summary.text) { |msg|
            yield(tid, msg) if block_given?
          }
        end
        syns_node = topic_node.at_xpath("Synonyms")
        synonyms = []
        unless syns_node.nil?
          syns_node.xpath("Synonym").each { |syn| synonyms << syn.text.strip }
          synonyms
        end
        groups_node = topic_node.at_xpath("Groups")
        related_gids = []
        unless groups_node.nil?
          groups_node.xpath("Group").each { |group_node|
            gid = group_node.at_xpath("GroupID").text.to_i rescue nil
            group_name = group_node.at_xpath("GroupName").text.strip
            group_url = group_node.at_xpath("GroupURL").text.strip
            groups[gid] = {} unless groups.key? gid
            groups[gid][locale] = {:medline_title => group_name, :medline_url => group_url}
            related_gids << gid
          }
        end
        related_topics_node = topic_node.at_xpath("RelatedTopics")
        related_tids = if related_topics_node.nil?
          []
        else
          rtids = []
          related_topics_node.xpath("RelatedTopic").each { |related_topic_node|
            rtid = related_topic_node['IDREF'][1..-1].to_i rescue nil
            rtids << rtid unless rtid.nil?
          }
          rtids
        end
        mesh_heads = parse_medline_xml_meshheads(topic_node)
        if mesh_heads.empty?
          # note: only go after first SeeReference
          mesh_heads = parse_medline_xml_meshheads(topic_node.xpath("SeeReferencesList/SeeReference"))
        end
        mesh_titles = mesh_heads.join(MESH_TITLE_SEPARATOR)
        topics[tid] = {
          :medline_title => medline_title,
          :locale => locale,
          :lang_map => lmtid,
          :synonyms => synonyms.sort,
          :summary_html => linted_summary,
          :medline_url => medline_url,
          :mesh_titles => mesh_titles,
          :related_groups => related_gids.sort,
          :related_topics => related_tids.sort
        }
      }
      {:topics => topics, :groups => groups}
    end

    def ensym_string_keys(o)
      if o.is_a? Hash
        new_hash = {}
        o.each { |key, value|
          key = (key =~ /\d+/) ? key.to_i : key.to_sym
          new_hash[key] = (value.kind_of? Hash) ? ensym_string_keys(value) : value
        }
        o = new_hash
      elsif o.is_a? Array
        o = o.collect { |entry| ensym_string_keys(entry) }
      end
      o
    end


    def medline_batch_from_json_file(file_path)
      ensym_string_keys(JSON.parse(File.read(file_path)))
    end


    def lint_html_text_or_ent(children)
      linted_xml = ""
      children.each { |child|
        if [Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::ENTITY_REF_NODE].include? child.node_type
          linted_xml << child.to_xml.gsub(/\s+/, " ")
        else
          yield("only text allowed here: #{child.to_s}") if block_given?
        end
      }
      linted_xml
    end


    def acceptable_summary_url?(url)
      begin
        URI::parse(url)
      rescue Exception
        return false
      end
      ACCEPTABLE_SYMMARY_URL_PREFIXES.each { |prefix| return true if url.start_with? prefix }
      false
    end


    def lint_html_body(children)
      linted_xml = ""
      children.each { |child|
        if [Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::ENTITY_REF_NODE].include? child.node_type
          linted_xml << child.to_xml.gsub(/\s+/, " ")
        elsif child.elem?
          if child.name == "a"
            if child.attributes.size == 1 && child['href']
              href_url = child['href']
              if acceptable_summary_url?(href_url)
                linted_xml << "<a href=\"#{href_url}\">"
                linted_xml << lint_html_text_or_ent(child.children) { |msg| yield(msg) }
                linted_xml << "</a>"
              else
                linted_xml << lint_html_text_or_ent(child.children) { |msg| yield(msg) }
                yield("non-medline href to " + href_url) if block_given?
              end
            else
              linted_xml << lint_html_text_or_ent(child.children) { |msg| yield(msg) }
              yield("<a> should only contain href attribute") if block_given?
            end
          elsif child.name == "em"
            if child.attributes.size > 0
              yield("<em> should contain no attributes") if block_given?
            end
            if child.at_xpath("a").nil?
              linted_xml << "<em>"
              linted_xml << lint_html_text_or_ent(child.children) { |msg| yield(msg) }
              linted_xml << "</em>"
            else
              # if the <em> contains an <a>, then turn everything into an <a>
              # TODO: should probably be more careful about this even though for todays data this seems to do the right thing
              linted_xml << lint_html_body(child.children) { |msg| yield(msg) }
            end
          end
        end
      }
      linted_xml.strip
    end


    def lint_medline_topic_summary_node(xml_root)

      return nil if xml_root.nil?

      if xml_root.children.size == 0
        yield("empty") if block_given?
        return nil
      end

      linted_xml = ""

      xml_root.children.each { |child|
        if child.text?
          unless child.text.strip.empty?
            yield("ignored root text outside p or li: #{child.text}") if block_given?
          end
        elsif child.elem?
          tag_name = child.name
          if child.name == "p"
            if child.attributes.size > 0
              if child['style'].nil?
                yield("<p> should contain no attributes") if block_given?
              end
            else
              linted_xml << "<p>"
              linted_xml << lint_html_body(child.children) { |msg| yield(msg) }
              linted_xml << "</p>"
            end
          elsif child.name == "ul"
            if child.attributes.size > 0
              yield("<ul> should contain no attributes")
            end
            linted_xml << "<ul>"
            child.children.each { |li|
              if li.elem?
                if li.name == "li"
                  if li.attributes.size > 0
                    yield("<li> should contain no attributes") if block_given?
                  end
                  linted_xml << "<li>"
                  linted_xml << lint_html_body(li.children) { |msg| yield(msg) }
                  linted_xml << "</li>"
                else
                  yield("ignored #{li.name} under <ul>") if block_given?
                end
              else
                unless li.text? && li.text.strip.empty?
                  yield("ignored under <ul>: #{li.to_s.strip}") if block_given?
                end
              end
            }
            linted_xml << "</ul>"
          else
            yield("ignored all root tags but p or ul: #{tag_name}") if block_given?
          end
        end
      }

      linted_xml
    end


    def lint_medline_topic_summary_html(unlinted_xml)

      return nil if unlinted_xml.nil?

      begin
        xml_root = Nokogiri::XML.fragment(unlinted_xml)
      rescue Exception => e
        yield("could not parse: #{e.message}") if block_given?
        return nil
      end

      lint_medline_topic_summary_node(xml_root) { |msg| yield(msg) if block_given? }

    end


    def apply_vocab_delta(deltas)

      synonyms = {}
      related_topics = {}
      related_groups = {}
      lang_mapped_topics = {}

      (deltas[:delete_group] || []).each { |group_key|
        group = MedGroup.first(:conditions => group_key)
        unless group.nil?
          group.topic_relaters.delete_all
          group.delete
        end
      }

      (deltas[:delete_topic] || []).each { |topic_key|
        topic = first(:conditions => topic_key)
        unless topic.nil?
          topic.synonyms.delete_all
          topic.group_relatees.delete_all
          topic.topic_relatees.delete_all
          topic.topic_relaters.delete_all
          topic.delete
        end
      }

      (deltas[:create_group] || {}).each { |group_key, group_atts|
        new_group_atts = group_key.clone
        group_atts.each { |name, value| new_group_atts[name] = value }
        MedGroup.create(new_group_atts)
      }

      (deltas[:create_topic] || {}).each { |topic_key, topic_atts|
        new_atts = topic_key.clone
        new_synonyms = []
        new_related_topics = []
        new_related_groups = []
        new_lmtid = nil
        topic_atts.each { |name, value|
          case name
            when :synonyms
              new_synonyms = value
            when :related_topics
              new_related_topics = value
            when :related_groups
              new_related_groups = value
            when :lang_map
              new_lmtid = value unless value.nil?
            else
              new_atts[name] = value
          end
        }

        new_topic = create!(new_atts)
        lang_mapped_topics[new_topic] = new_lmtid

        # only need to patch these in if there are any
        synonyms[new_topic] = new_synonyms unless new_synonyms.empty?
        related_topics[new_topic] = new_related_topics unless new_related_topics.empty?
        related_groups[new_topic] = new_related_groups unless new_related_groups.empty?
      }

      (deltas[:update_group] || {}).each { |group_key, changed_group_atts|
        unless changed_group_atts.empty?
          group = MedGroup.first(:conditions => group_key)
          unless group.nil?
            group.attributes = changed_group_atts
            group.save
          end
        end
      }

      (deltas[:update_topic] || {}).each { |topic_key, topic_atts|
        unless topic_atts.empty?
          topic = find(:first, :conditions => topic_key)
          unless topic.nil?
            changed_topic_atts = {}
            topic_atts.each { |name, value|
              case name
                when :synonyms
                  synonyms[topic] = value
                when :related_topics
                  related_topics[topic] = value
                when :related_groups
                  related_groups[topic] = value
                when :lang_map
                  lang_mapped_topics[topic] = value unless (value.nil? && topic.lang_mapped_topic.nil?)
                when :medline_tid
                else
                  changed_topic_atts[name] = value
              end
            }
            unless changed_topic_atts.empty?
              topic.attributes = changed_topic_atts
              topic.save!
            end
          end
        end
      }


      # patch up related synonyms

      synonyms.each { |topic, syns|
        topic.synonyms.delete_all
        syns.each { |syn| topic.synonyms.create({:medline_title => syn}) }
      }


      # patch up related topics

      related_topics.each { |topic, related_tids|
        topic.topic_relatees.delete_all
        related_tids.each { |related_tid|
          related_topic = MedTopic.first(:conditions => {:medline_tid => related_tid})
          topic.topic_relatees.create({:related_topic => related_topic}) unless related_topic.nil?
        }
      }


      # patch up related groups

      related_groups.each { |topic, related_gids|
        topic.group_relatees.delete_all
        related_gids.each { |related_gid|
          related_group = MedGroup.first(:conditions => { :medline_gid => related_gid, :locale => topic.locale })
          topic.group_relatees.create({ :group => related_group }) unless related_group.nil?
        }
      }

      # patch up lang mapped topics

      lang_mapped_topics.each { |topic, lang_map_tid|
        topic.lang_mapped_topic = MedTopic.first(:conditions => {:medline_tid => lang_map_tid})
        topic.save!
      }

    end


#	TODO: sub-optimal, should optimize once search interface details are known
#   for now, return ordered list of matches, given preference to locale match
#   over direct tytle (as opposed to synonym) match

    def search_for(title, locale = "en")
      stripped_title = title.strip
      matched_topic = where(:medline_title => stripped_title, :visible => true, :locale => locale).limit(1).first
      unless matched_topic
        matched_synonym = MedSynonym.where(:medline_title => stripped_title).select { |synonym| synonym.topic.locale == locale }.first
        matched_topic = matched_synonym.topic if matched_synonym
      end
      matched_topic
    end


    def lint_medline_xml_for_date(effective_date)

      xml = MedTopic.medline_xml_for_date(effective_date)
      vocab = MedTopic.parse_medline_xml_vocab(xml) { |where, what| yield("#{where}: #{what}") }

      yield "found #{vocab[:topics].size} topics / #{vocab[:groups].size} groups"
      topics_wo_langmap = {}
      topics_wo_groups = []
      vocab[:topics].each { |tid, topic_atts|
        topics_wo_groups << [tid, topic_atts[:medline_title]] if topic_atts[:related_groups].nil? || topic_atts[:related_groups].empty?
        (topics_wo_langmap[topic_atts[:locale]] ||= []) << [tid, topic_atts[:medline_title]] if topic_atts[:lang_map].nil? || topic_atts[:lang_map] == 0
      }

      unless topics_wo_groups.empty?
        yield "#{topics_wo_groups.size} topics without groups:"
        topics_wo_groups.each { |topic_info| yield "  #{topic_info.join(": ")}" }
      end

      unless topics_wo_langmap.empty?
        yield "single-locale topics:"
        topics_wo_langmap.each { |locale, topics|
          topics.each { |topic_info| yield "  #{topic_info.join(": ")}" }
        }
      end

    end

  end

end

