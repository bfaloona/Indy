require "#{File.dirname(__FILE__)}/helper"

describe 'Indy#last' do

  context "method" do

    before(:each) do
      log_string = ["2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
                    "2000-09-08 14:08:41 INFO  MyOtherApp - Exiting APPLICATION.",
                    "2000-09-09 14:07:00 INFO  MyOtherApp - Exiting APPLICATION.",
                    "2000-09-10 14:08:00 INFO  MyOtherApp - Exiting APPLICATION.",
                    "2000-09-10 14:09:00 INFO  MyOtherApp - Exiting APPLICATION.",
                    "2000-09-10 14:09:30 INFO  MyOtherApp - Exiting APPLICATION.",
                    "2000-09-10 14:10:55 INFO  MyApp - Exiting APPLICATION."].join("\n")
      @indy = Indy.search(log_string)
    end

    it "should be a method" do
      @indy.should.respond_to?( :last )
      puts 'bad test!!'
      puts @indy.last
    end

    it "should return self" do
      @indy.last(1).should be_kind_of? Indy
    end

    it "should raise an error if passed an invalid parameter" do
      lambda{ @indy.last('a') }.should raise_error( ArgumentError )
      lambda{ @indy.last() }.should raise_error( ArgumentError )
      lambda{ @indy.last(nil) }.should raise_error( ArgumentError )
      lambda{ @indy.last([]) }.should raise_error( ArgumentError )
    end

    it "should return correct number of rows when passed a number" do
      @indy.last( 3 ).for(:all).length.should == 3
    end

    it "should return correct number of rows when passed a span of minutes" do
      @indy.last( :span => 2).for(:all).length.should == 3
    end

    it "should return correct rows when passed a span of minutes" do
      @indy.last( :span => 3).for(:all).first.time.should == '2000-09-10 14:08:00'
    end

    
  end

end