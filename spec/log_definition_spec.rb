require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy/log_definition")

describe 'Indy::LogDefinition' do

  context '#new' do

    context "with a valid hash" do

      before(:each) do
        @ld = Indy::LogDefinition.new(:entry_regexp => /foo/, :entry_fields => [:field_one], :time_format => '%M-%d-%Y')
      end

      it "should set entry_regexp" do
        @ld.entry_regexp.should eq /foo/
      end

      it "should set entry_fields" do
        @ld.entry_fields.should eq [:field_one]
      end

      it "should set time_format" do
        @ld.time_format.should eq '%M-%d-%Y'
      end

    end

    it "should raise ArgumentError when missing entry_fields" do
      lambda{ Indy::LogDefinition.new(:entry_regexp => /foo/) }.should raise_error ArgumentError
    end

    it "should raise ArgumentError when missing entry_regexp" do
      lambda{ Indy::LogDefinition.new(:entry_fields => [:field_one]) }.should raise_error ArgumentError
    end

  end

  context 'private method' do

    before(:each) do
      @ld = Indy::LogDefinition.new(:entry_regexp => /^(\S+) (\S+) (.+)$/,
                              :entry_fields => [:time, :severity, :message],
                              :time_format => '%M-%d-%Y')
      @field_captures = "2000-09-07 INFO The message!".match(@ld.entry_regexp).to_a
    end

    context "#parse_entry" do

      it "should return a hash" do
        @ld.send(:parse_entry, "2000-09-07 INFO The message!").class.should == Hash
      end

      it "should return correct key/value pairs" do
        hash = @ld.send(:parse_entry, "2000-09-07 INFO The message!")
        hash[:time].should == "2000-09-07"
        hash[:message].should == "The message!"
      end

    end

    context "#parse_entry_captures" do

      it "should return a hash" do
        @ld.send(:parse_entry_captures, @field_captures).class.should == Hash
      end

      it "should contain key/value pairs" do
        hash = @ld.send(:parse_entry_captures, @field_captures)
        hash[:time].should == "2000-09-07"
        hash[:message].should == "The message!"
      end

    end

  end
end
