module ActionController
  module MobileFu
    
    # These are various strings that can be found in mobile devices.  Please feel free
    # to add on to this list.
    
    
    MOBILE_USER_AGENTS =  'palm|palmos|palmsource|iphone|blackberry|nokia|phone|midp|mobi|pda|' +
                          'wap|java|nokia|hand|symbian|chtml|wml|ericsson|lg|audiovox|motorola|' +
                          'samsung|sanyo|sharp|telit|tsm|mobile|mini|windows ce|smartphone|' +
                          '240x320|320x320|mobileexplorer|j2me|sgh|portable|sprint|vodafone|' +
                          'docomo|kddi|softbank|pdxgw|j-phone|astel|minimo|plucker|netfront|' +
                          'xiino|mot-v|mot-e|portalmmm|sagem|sie-s|sie-m|android|ipod|opwv-sdk'
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      # Add this to one of your controllers to use MobileFu.  
      #
      #    class ApplicationController < ActionController::Base 
      #      has_mobile_fu
      #    end
      #
      # You can also force mobile mode by passing in 'true'
      #
      #    class ApplicationController < ActionController::Base 
      #      has_mobile_fu(true)
      #    end
        
      def has_mobile_fu(test_mode = false)
        include ActionController::MobileFu::InstanceMethods

        if test_mode 
          before_filter :force_mobile_format
        else
          before_filter :set_mobile_format
        end

        helper_method :is_mobile_device?
        helper_method :in_mobile_view?
        helper_method :is_device?
      end
      
      def is_mobile_device?
        @@is_mobile_device
      end

      def in_mobile_view?
        @@in_mobile_view
      end

      def is_device?(type)
        @@is_device
      end
    end

    module InstanceMethods
      
      # Forces the request format to be :mobile
      
      def force_mobile_format
        request.format = :mobile
      end
      
      # Determines the request format based on whether the device is mobile or if
      # the user has opted to use either the 'Standard' view or 'Mobile' view.
      
      def set_mobile_format
        # coming into the site, the mobile mode should be set automatically if the user
        # is using a mobile device
        if is_mobile_device?
          request.params[:mobile] = "true"
        end
        
        request.format = request.params[:mobile] == "true" ? :mobile : :html
      end
      
      # Returns either true or false depending on whether or not the format of the
      # request is either :mobile or not.
      
      def in_mobile_view?
        request.format.to_sym == :mobile
      end
      
      # Returns either true or false depending on whether or not the user agent of
      # the device making the request is matched to a device in our regex.
      
      def is_mobile_device?
        request.user_agent.to_s.downcase =~ Regexp.new(ActionController::MobileFu::MOBILE_USER_AGENTS)
      end

      # Can check for a specific user agent
      # e.g., is_device?('iphone') or is_device?('mobileexplorer')
      
      def is_device?(type)
        request.user_agent.to_s.downcase.include?(type.to_s.downcase)
      end
    end
    
  end
  
end

ActionController::Base.send(:include, ActionController::MobileFu)

