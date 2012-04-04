require "#{File.dirname(__FILE__)}/../lib/indy/fast_source.rb"

class Indy

  describe FastSource do

    context "Normal data" do

      before(:all) do
        @log = "1,one\n2,two\n3,three\n4,four\n5,five\n6,six\n7,seven\n8,eight\n9,nine\n10,ten\n"
      end

      it "should return begin/end index array for value_range before middle" do
        value_range = 4..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [3,7]
      end

      it "should return begin/end index array for value_range at beginning" do
        value_range = 1..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [0,7]
      end

      it "should return begin/end index array for value_range just before middle" do
        value_range = 5..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [4,7]
      end

      it "should return begin/end index array for value_range after middle" do
        value_range = 7..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [6,7]
      end

      it "should return begin/end index array for value_range at middle" do
        value_range = 6..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [5,7]
      end

      it "should return begin/end index array for value_range at end" do
        value_range = 10..11
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [9,9]
      end

    end

    context "Normal data" do

      before(:all) do
        @log = ''
        20000.times { |i| i += 1; @log << i.to_s + ",#{i} value\n" }
      end

      it "should work with large data set" do

        value_range = 4301..5100
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [4300,5099]
      end

    end
    
    context "Abnormal data" do

      before(:all) do
        @log = "1,one\n2,two\n2,two\n2,two\n4,four\n5,five\n7,seven\n8,eight\n8,eight\n10,ten\n"
      end

      it "should return begin/end index array for value_range multiple end values" do
        value_range = 4..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [4,8]
      end
      
      it "should return begin/end index array for value_range multiple begin values" do
        value_range = 2..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(value_range).should == [1,8]
      end
    end

  end
end
