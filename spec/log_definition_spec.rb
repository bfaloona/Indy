require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy/log_definition")

describe 'Indy::LogDefinition' do

  context '#new' do

    context "with a valid hash" do

      before(:each) do
        @ld = Indy::LogDefinition.new(:entry_regexp => /foo/, :entry_fields => [:field_one], :time_format => '%M-%d-%Y')
      end

      it "should set entry_regexp" do
        expect(@ld.entry_regexp).to eq /foo/
      end

      it "should set entry_fields" do
        expect(@ld.entry_fields).to eq [:field_one]
      end

      it "should set time_format" do
        expect(@ld.time_format).to eq '%M-%d-%Y'
      end

    end

    it "should raise ArgumentError when missing entry_fields" do
      expect{ Indy::LogDefinition.new(:entry_regexp => /foo/) }.to raise_error ArgumentError
    end

    it "should raise ArgumentError when missing entry_regexp" do
      expect{ Indy::LogDefinition.new(:entry_fields => [:field_one]) }.to raise_error ArgumentError
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
        expect(@ld.send(:parse_entry, "2000-09-07 INFO The message!").class).to eq(Hash)
      end

      it "should return correct key/value pairs" do
        hash = @ld.send(:parse_entry, "2000-09-07 INFO The message!")
        expect(hash[:time]).to eq("2000-09-07")
        expect(hash[:message]).to eq("The message!")
      end

    end

    context "#parse_entry_captures" do

      it "should return a hash" do
        expect(@ld.send(:parse_entry_captures, @field_captures).class).to eq(Hash)
      end

      it "should contain key/value pairs" do
        hash = @ld.send(:parse_entry_captures, @field_captures)
        expect(hash[:time]).to eq("2000-09-07")
        expect(hash[:message]).to eq("The message!")
      end

    end

  end
end
