
class Indy

  VERSION = '0.4.0.pre'

  def self.show_version_changes(version)
    date = ""
    changes = []
    grab_changes = false

    File.open("#{File.dirname(__FILE__)}/../../History.txt",'r') do |file|
      while (line = file.gets) do

        if line =~ /^===\s*#{version.gsub('.','\.')}\s*\/\s*(.+)\s*$/
          grab_changes = true
          date = $1.strip
        elsif line =~ /^===\s*.+$/
          grab_changes = false
        elsif grab_changes
          changes = changes << line
        end

      end
    end

    { :date => date, :changes => changes }
  end

end
