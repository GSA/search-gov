module ActionView
  module Helpers
    module FormOptionsHelper
      def us_state_options_for_select(selected = nil, us_state_options = {})
        state_options      = ""
        priority_states    = lambda { |state| us_state_options[:priority].include?(state.last) }
        us_state_options[:show] = :full if us_state_options[:with_abbreviation]
        states_label = case us_state_options[:show]
          when :full_abb          then lambda { |state| [state.first, state.last] }
          when :full              then lambda { |state| [state.first, state.first] }
          when :abbreviations     then lambda { |state| [state.last, state.last] }
          when :abb_full_abb      then lambda { |state| ["#{state.last} - #{state.first}", state.last] }
          else                         lambda { |state| state }
        end

        if us_state_options[:include_blank]
          state_options += "<option value=\"\">--</option>\n"
        end

        if us_state_options[:priority]
          state_options += options_for_select(US_STATES.select(&priority_states).collect(&states_label), selected)
          state_options += "<option value=\"\">--</option>\n"
        end

        if us_state_options[:priority] && us_state_options[:priority].include?(selected)
          state_options += options_for_select(US_STATES.reject(&priority_states).collect(&states_label), selected)
        else
          state_options += options_for_select(US_STATES.collect(&states_label), selected)
        end

        return state_options
      end

      def us_state_select(object, method, us_state_options = {}, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_us_state_select_tag(us_state_options, options, html_options)
      end

      private
        US_STATES = [["Alaska", "AK"], ["Alabama", "AL"], ["Arkansas", "AR"], ["Arizona", "AZ"], 
                     ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["District of Columbia", "DC"], 
                     ["Delaware", "DE"], ["Florida", "FL"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Iowa", "IA"], 
                     ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Kansas", "KS"], ["Kentucky", "KY"], 
                     ["Louisiana", "LA"], ["Massachusetts", "MA"], ["Maryland", "MD"], ["Maine", "ME"], ["Michigan", "MI"], 
                     ["Minnesota", "MN"], ["Missouri", "MO"], ["Mississippi", "MS"], ["Montana", "MT"], ["North Carolina", "NC"], 
                     ["North Dakota", "ND"], ["Nebraska", "NE"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], 
                     ["New Mexico", "NM"], ["Nevada", "NV"], ["New York", "NY"], ["Ohio", "OH"], ["Oklahoma", "OK"], 
                     ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], 
                     ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Virginia", "VA"], ["Vermont", "VT"], 
                     ["Washington", "WA"], ["Wisconsin", "WI"], ["West Virginia", "WV"], ["Wyoming", "WY"]] unless const_defined?("US_STATES")

    end

    class InstanceTag #:nodoc:
      # lets the us_states plugin handle Rails 1.1.2 AND trunk
      def value_with_compat(object=nil)
        if method(:value_without_compat).arity == 1
          value_without_compat(object)
        else
          value_without_compat
        end
      end
      alias_method :value_without_compat, :value
      alias_method :value, :value_with_compat

      def to_us_state_select_tag(us_state_options, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        content_tag("select", add_options(us_state_options_for_select(value(object), us_state_options), options, value(object)), html_options)
      end
    end
    
    class FormBuilder
      def us_state_select(method, us_state_options = {}, options = {}, html_options = {})
        @template.us_state_select(@object_name, method, us_state_options, options.merge(:object => @object), html_options)
      end
    end
  end
end
