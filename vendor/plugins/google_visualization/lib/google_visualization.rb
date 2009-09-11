# GoogleVisualization
module GoogleVisualization
  class MotionChart

    attr_reader :collection, :collection_methods, :options, :size, :helpers, :procedure_hash, :name

    def method_missing(method, *args, &block)
      if Mappings.columns.include?(method)
        procedure_hash[method] = [args[0], block]
      else
        helpers.send(method, *args, &block)
      end
    end

    def initialize(view_instance, collection, options={}, *args)
      @helpers = view_instance
      @collection = collection
      @collection_methods = collection_methods
      @options = options.reverse_merge({:width => 600, :height => 300})
      @columns = []
      @rows = []
      @procedure_hash = {:color => ["Department", lambda {|item| label_to_color(@procedure_hash[:label][1].call(item)) }] }
      @size = collection.size
      @name = "motion_chart_#{self.object_id.to_s.gsub("-","")}"
      @labels = {}
      @color_count = 0
    end

    def header
      content_tag(:div, "", :id => name, :style => "width: #{options[:width]}px; height: #{options[:height]}px;")
    end

    def body
      javascript_tag do
        "var data = new google.visualization.DataTable();\n" +
        "data.addRows(#{size});\n" +
        render_columns +
	render_rows +
        "var #{name} = new google.visualization.MotionChart(document.getElementById('#{name}'));\n" +
        "#{name}.draw(data, {width: #{options[:width]}, height: #{options[:height]}});"
      end
    end

    def render
      header + "\n" + body
    end

    def render_columns
      if required_methods_supplied?
        Mappings.columns.each { |c| @columns << motion_chart_add_column(procedure_hash[c]) }
        procedure_hash.each { |key, value| @columns << motion_chart_add_column(value) if not Mappings.columns.include?(key) }
        @columns.join("\n")
      end
    end

    def render_rows
      if required_methods_supplied?
        collection.each_with_index do |item, index|
          Mappings.columns.each_with_index {|name,column_index| @rows << motion_chart_set_value(index, column_index, procedure_hash[name][1].call(item)) }
          procedure_hash.each {|key,value| @rows << motion_chart_set_value(index, key, procedure_hash[key][1].call(item)) unless Mappings.columns.include?(key) }
        end
        @rows.join("\n")
      end
    end

    def required_methods_supplied?
      Mappings.columns.each do |key|
        unless procedure_hash.has_key? key
          raise "MotionChart Must have the #{key} method called before it can be rendered"
	end
      end
    end

    def motion_chart_add_column(title_proc_tuple)
      title = title_proc_tuple[0]
      procedure = title_proc_tuple[1]
      "data.addColumn('#{google_type(procedure)}','#{title}');\n"
    end

    def motion_chart_set_value(row, column, value)
      "data.setValue(#{row}, #{column}, #{Mappings.ruby_to_javascript_object(value)});\n"
    end

    def google_type(procedure)
      Mappings.ruby_to_google_type(procedure.call(collection[0]).class)
    end

    def google_formatted_value(value)
      Mappings.ruby_to_javascript_object(value)
    end

    def label_to_color(label)
      hashed_label = label.downcase.gsub(" |-","_").to_sym
      if @labels.has_key? hashed_label
        @labels[hashed_label]
      else
        @color_count += 1
	@labels[hashed_label] = @color_count
      end
    end

    def extra_column(title, &block)
      procedure_hash[procedure_hash.size] = [title, block]
    end

  end

  class AnnotatedTimeLine
    attr_reader :collection, :options, :helpers, :dates, :lines

    def method_missing(method, *args, &block)
      if Mappings.columns.include?(method)
        procedure_hash[method] = [args[0], block]
      else
        helpers.send(method, *args, &block)
      end
    end

    def initialize(view_instance, dates, options={}, *args)
      @helpers = view_instance
      @dates = dates
      @options = options.reverse_merge({:width => 600, :height => 300})
      @lines = []
      @name = "annotated_timeline_#{self.object_id.to_s.gsub("-","")}"
      @heading_count = 1
      @headings = ""
      @data = ""
      @row_length = 0;
    end

    def render_head
      "<div id=\"#{@name}\" style=\"width: #{@options[:width]}px; height: #{@options[:height]}px;\"></div>\n" +
        "<script type=\"text/javascript\">\n" +
        "var #{@name}_data = new google.visualization.DataTable();\n"
    end

    def render_foot
      "var #{@name} = new google.visualization.AnnotatedTimeLine(document.getElementById('#{@name}'));" +
        "#{@name}.draw(#{@name}_data, {displayAnnotations: true});\n</script>"
    end

    def render_headings
      add_heading('date', 'Date')
      @lines.each do |line_hash|
          add_headings_for(line_hash)
      end
      @headings
    end

    def render_data
      row_count = 0
      @dates.each_with_index do |date, index|
        add_row(row_count, 0, date)
        @lines.each do |line_hash|
          if line_hash[:collection][index]
            add_row(row_count, line_hash[:column_start], line_hash[:collection][index].send(line_hash[:method_hash][:value]))
            add_row(row_count, line_hash[:column_start]+1, line_hash[:collection][index].send(line_hash[:method_hash][:title])) if line_hash[:method_hash][:title] and line_hash[:collection][index].send(line_hash[:method_hash][:title])
            add_row(row_count, line_hash[:column_start]+2, line_hash[:collection][index].send(line_hash[:method_hash][:notes])) if line_hash[:method_hash][:notes] and line_hash[:collection][index].send(line_hash[:method_hash][:notes])
          end
        end
        row_count += 1
      end
      @data
    end

    def render
      render_head + render_headings + "#{@name}_data.addRows(#{@row_length});\n" + render_data + render_foot
    end

    def add_headings_for(line_hash)
      line_hash[:column_start] = @heading_count
      add_heading('number',line_hash[:title])
      add_heading('string', "title#{@heading_count}")
      add_heading('string', "notes#{@heading_count}")
      @heading_count += 3
    end

    def add_heading(type, name)
      @headings += "#{@name}_data.addColumn('#{type}','#{name}');\n"
    end

    def add_row(row, column, value)
      @data += "#{@name}_data.setValue(#{row}, #{column}, #{Mappings.ruby_to_javascript_object(value)});\n"
    end

    def add_line(title, collection, method_hash)
      required_methods_supplied? method_hash
      collection.size > @row_length ? @row_length = collection.size : @row_length
      @lines.push({:title => title, :collection => collection,:method_hash => method_hash})
    end

    def required_methods_supplied?(method_hash)
      if method_hash.has_key?(:value)
        true
      else
        raise "Add Line requires the :value key to be specified in the method_hash"
      end
    end


  end

  module Mappings
    def self.ruby_to_google_type(type)
      type_hash = {
        :String => "string",
        :Fixnum => "number",
        :Float => "number",
        :Date => "date",
        :Time => "datetime"
      }
      type_hash[type.to_s.to_sym]
    end

    def self.ruby_to_javascript_object(value)
      value_hash = {
        :String => lambda {|v| "'#{v}'"},
        :Date => lambda {|v| "new Date(#{[v.year,(v.month.to_i - 1),v.day].join(',')})"},
        :Fixnum => lambda {|v| v },
	:Float => lambda {|v| v }
      }
      value_hash[value.class.to_s.to_sym].call(value)
    end

    def self.columns
      [:label, :time, :x, :y, :color, :bubble_size]
    end
  end

  module Helpers
    def setup_google_visualizations
      "<script type=\"text/javascript\" src=\"http://www.google.com/jsapi\"></script>\n" +
      javascript_tag("google.load(\"visualization\", \"1\", {packages:[\"motionchart\", \"annotatedtimeline\"]});")
    end

    def motion_chart_for(collection, options={}, *args, &block)
      motion_chart = MotionChart.new(self, collection, options)
      yield motion_chart
      concat(motion_chart.render)
    end

    def annotated_timeline_for(dates, options={}, *args, &block)
      annotated_timeline = AnnotatedTimeLine.new(self, dates, options)
      yield annotated_timeline
      concat(annotated_timeline.render)
    end
  end
end
