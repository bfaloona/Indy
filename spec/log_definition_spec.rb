require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy/log_definition")

describe 'LogDefinition' do

  context '#new' do

    context "with a valid hash" do

      before(:each) do
        @ld = LogDefinition.new(:entry_regexp => /foo/, :entry_fields => [:field_one], :time_format => '%M-%d-%Y', :time_field => :the_time)
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

      it "should set time_field" do
        @ld.time_field.should eq :the_time
      end

    end

    it "should raise ArgumentError when missing entry_fields" do
      pending "LogDefinition initialization should be more strict"
      lambda{ LogDefinition.new(:entry_regexp => /foo/, :entry_fields => [:field_one], :time_format => '%M-%d-%Y', :time_field => :the_time) }.should raise_error ArgumentError
    end

  end
end
