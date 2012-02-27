require "#{File.dirname(__FILE__)}/../lib/indy/fast_source.rb"

class Indy

  describe FastSource do

    context "Normal data" do

      before(:all) do
        @log = "1,one\n2,two\n3,three\n4,four\n5,five\n6,six\n7,seven\n8,eight\n9,nine\n10,ten\n"
      end

      it "should return the first id in range before middle" do
        range = 4..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(range).should == 3
      end

      it "should return the first id in range at beginning" do
        range = 1..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(range).should == 0
      end

      it "should return the first id in range just before middle" do
        range = 5..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(range).should == 4
      end

      it "should return the first id in range after middle" do
        range = 7..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(range).should == 6
      end

      it "should return the first id in range just after middle" do
        range = 6..8
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(range).should == 5
      end

      it "should return the first id in range at end" do
        range = 10..11
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(range).should == 9
      end

    end

    context "Normal data" do

      before(:all) do
        @log = ''
        20000.times { |i| i += 1; @log << i.to_s + ",#{i} value\n" }
      end

      it "should work with large data set" do

        range = 4301..5100
        fs = FastSource.new
        fs.open(@log)
        fs.scoped_source(range).should == 4300
      end

    end

  end
end