require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy/buffered_file")

def create_100_line_file
  file = Tempfile.new('file')
  file.write("first\n")
  file.write("second\n")
  (3..51).each do |num|
    file.write(num.to_s * 10 + "\n")
  end
  file.write("fiftytwo\n")
  (53..98).each do |num|
    file.write(num.to_s * 10 + "\n")
  end
  file.write("penultimate\n")
  file.write("last\n")
  file.close
  file
end

describe 'BufferedFile' do

  require 'tempfile'

  context ':initialize' do

    it "should accept a file" do
      BufferedFile.new(Tempfile.new('bufferedfile'))
    end

    it "should require a file" do
      lambda{BufferedFile.new("my log\nis a string!")}.should raise_error(ArgumentError)
    end

    it "should provide the file size as @file_size" do
      f = Tempfile.new('filesize')
      f.write('1234567890')
      f.flush
      BufferedFile.new(f).file_size.should == 10
    end

    it "should default @buffer_size to 128_000" do
      f = Tempfile.new('filesize')
      f.write('1234567890' * 100 * 130) # 130k
      f.flush
      b = BufferedFile.new(f)
      b.buffer_size.should eq 128_000
    end

    it "should require @buffer_size to be smaller than @file_size" do
      f = Tempfile.new('filesize')
      f.write('1234567890' * 100)
      f.flush
      b = BufferedFile.new(f)
      b.file_size.should == 1_000
      b.buffer_size = 20_000
      b.buffer_size.should eq 1_000
    end

  end

  context "[] access" do

    {:penultimate => 98, :fiftytwo => 51, :first => 0, :second => 1}.each do |entry|
      it "should support #{entry[0]} entry" do
        index = entry[1]
        b = BufferedFile.new(create_100_line_file)
        b[index].should eq entry[0].to_s
      end

      it "should support #{entry[0]} entry when file exceeds buffer size" do
        index = entry[1]
        b = BufferedFile.new(create_100_line_file)
        b.buffer_size = 40
        b[index].should eq entry[0].to_s
      end
    end

    {:fiftytwo => -49, :penultimate => -2, :last => -1}.each do |entry|
      it "should support #{entry[0]} entry using negative index" do
        index = entry[1]
        b = BufferedFile.new(create_100_line_file)
        b[index].should eq entry[0].to_s
      end

      it "should support #{entry[0]} entry using negative index when file exceeds buffer size" do
        index = entry[1]
        b = BufferedFile.new(create_100_line_file)
        b.buffer_size = 60
        b[index].should eq entry[0].to_s
      end

    end

    context "#each_entry" do

      it "should iterate through all records" do
        b = BufferedFile.new(create_100_line_file)
        entry_count = 0
        b.each_entry do |entry|
          entry_count += 1
        end
        entry_count.should eq 100
      end

      {:penultimate => 98, :fiftytwo => 51, :first => 0, :second => 1}.each do |entry|
        it "should support #{entry[0]} entry" do
          index = entry[1]
          b = BufferedFile.new(create_100_line_file)
          entry_under_test = entry[1]
          entry_count = 0
          b.each_entry do |actual_entry|
            if entry_count == entry[1]
              actual_entry.should eq entry[0].to_s
              entry_count += 1
            end
          end
        end
      end

      it "should retain all bytes" do
        b = BufferedFile.new(create_100_line_file)
        file_data = File.open(create_100_line_file.path).read
        iterated_data = ''
        b.each_entry do |entry|
          iterated_data += (entry + "\n")
        end
        iterated_data.should eq file_data
      end

    end
  end
end
