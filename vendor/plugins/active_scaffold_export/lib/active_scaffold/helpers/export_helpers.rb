# coding: utf-8

module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a Export Column
    module ExportHelpers
      def self.included(base)
        base.alias_method_chain :active_scaffold_stylesheets, :export
        base.alias_method_chain :active_scaffold_ie_stylesheets, :export
      end

      # Provides stylesheets to include with +stylesheet_link_tag+
      def active_scaffold_stylesheets_with_export(frontend = :default)
        active_scaffold_stylesheets_without_export.to_a << ActiveScaffold::Config::Core.asset_path("export-stylesheet.css", frontend)
      end

      # Provides stylesheets for IE to include with +stylesheet_link_tag+
      def active_scaffold_ie_stylesheets_with_export(frontend = :default)
        active_scaffold_ie_stylesheets_without_export.to_a << ActiveScaffold::Config::Core.asset_path("export-stylesheet-ie.css", frontend)
      end

      ## individual columns can be overridden by defining
      # a helper method <column_name>_export_column(record)
      # You can customize the output of all columns by
      # overriding the following helper methods:
      # format_export_column(raw_value)
      # format_singular_association_export_column(association_record)
      # format_plural_association_export_column(association_records)
      def get_export_column_value(record, column)
        if export_column_override? column
          send(export_column_override(column), record)
        else
          raw_value = record.send(column.name)

          if column.association.nil? or column_empty?(raw_value)
            format_export_column(raw_value)
          else
            case column.association.macro
            when :has_one, :belongs_to
              format_singular_association_export_column(raw_value)
            when :has_many, :has_and_belongs_to_many
              format_plural_association_export_column(raw_value)
            end
          end
        end
      end

      def export_column_override(column)
        "#{column.name.to_s.gsub('?', '')}_export_column" # parse out any question marks (see issue 227)
      end

      def export_column_override?(column)
        respond_to?(export_column_override(column))
      end

      def format_export_column(raw_value)
        format_value(raw_value)
      end

      def format_singular_association_export_column(association_record)
        format_value(association_record.to_label)
      end

      def format_plural_association_export_column(association_records)
        firsts = association_records.first(4).collect { |v| v.to_label }
        firsts[4] = "…" if firsts.length == 4
        format_value(firsts.join(','))
      end

      ## This helper can be overridden to change the way that the headers
      # are formatted. For instance, you might want column.name.to_s.humanize
      def format_export_column_header_name(column)
        column.name.to_s
      end
    end
  end
end
