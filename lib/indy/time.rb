require 'active_support'
require 'active_support/core_ext'

class Indy

  class Time

    class << self

      #
      # Return a valid DateTime object for the log entry string or hash
      #
      # @param [String, Hash] param The log entry string or hash
      #
      def parse_date(time,time_format=nil)
        return time if time.kind_of? ::Time or time.kind_of? DateTime
        if time_format
          begin
            # Attempt the appropriate parse method
            DateTime.strptime(time, time_format)
          rescue
            # If appropriate, fall back to simple parse method
            DateTime.parse(time) rescue nil
          end
        else
          begin
            # If appropriate, fall back to simple parse method
            ::Time.parse(time)
          rescue => e
            raise "Failed to create time object. The error was: #{e.message}"
            #begin
            #  # one last try!!
            #  DateTime.parse(time)
            #rescue Exception => e
            #  raise "Failed to create time object. The error was: #{e.message}"
            #end
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

      #
      # Evaluate if a log entry satisfies the configured time conditions
      #
      # @param [Hash] entry_hash The log entry's hash
      #
      def inside_time_window?(time_string,start_time,end_time,inclusive)
        time = Indy::Time.parse_date(time_string)
        #return false unless time && entry_hash
        if inclusive
          true unless time > end_time or time < start_time
        else
          true unless time >= end_time or time <= start_time
        end
      end

    end

  end

end