module RubyAv
  module Helpers
    class String
      def self.modularize_str(string)
        str = string.to_s.gsub('_', ' ')
        str = str.split(' ').map { |stf| stf.capitalize }
  
        str.join('')
      end
    end
  end
end
