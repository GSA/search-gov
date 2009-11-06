module ActionController
  module Routing
    class RouteSet
      def draw
        clear!
        map = Mapper.new(self)
        map.namespace :cablecar do |strong|
          strong.resources 'users'
        end
        
        yield map
        install_helpers                         
      end      
    end
  end
end