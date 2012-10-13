require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy/log_definition")

describe 'LogDefinition' do

  context ':initialize' do

    it "should set instance variables when passed a valid hash" do
      ld = LogDefinition.new(:entry_regexp => /foo/, :entry_fields => [:field_one], :time_format => '%M-%d-%Y', :time_field => :the_time)
      ld.entry_regexp.should eq /foo/
      ld.entry_fields.should eq [:field_one]
      ld.time_format.should eq '%M-%d-%Y'
      ld.time_field.should eq :the_time
    end


  end
end
