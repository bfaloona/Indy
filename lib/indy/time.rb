require 'active_support'
require 'active_support/core_ext'

class Indy

  class Time

    # Exception raised when unable to parse an entry's time value
    class ParseException < Exception; end

    class << self

      #
      # Return a valid DateTime object for the log entry string or hash
      #
      # @param [String, Hash] time The log entry string or hash
      #
      # @param [String] time_format String of #strftime directives to define format
      #
      def parse_date(time,time_format=nil)
        return time if time.kind_of? ::Time or time.kind_of? DateTime
        if time_format
          begin
            DateTime.strptime(time, time_format)
          rescue
            DateTime.parse(time) rescue nil
          end
        else
          begin
            ::Time.parse(time)
          rescue => e
            raise "Failed to create time object. The error was: #{e.message}"
          end
        end
      end

      #
      # Return a time or datetime object way in the future
      #
      def forever(time_format=nil)
        time_format ? DateTime.new(4712) : ::Time.at(0x7FFFFFFF)
      end

      #
      # Return a time or datetime object way in the past
      #
      def forever_ago(time_format=nil)
        begin
          time_format ? DateTime.new(-4712) : ::Time.at(-0x7FFFFFFF)
        rescue
          # Windows Ruby Time can't handle dates prior to 1969
          time_format ? DateTime.new(-4712) : ::Time.at(0)
        end
      end

    end
  end
end