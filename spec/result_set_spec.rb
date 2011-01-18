require "#{File.dirname(__FILE__)}/helper"

describe 'ResultSet' do

  it "should be Enumerable" do
    ResultSet.new.should be_kind_of(Enumerable)
  end

  context 'search results' do

    before(:all) do
      logcontent = "2000-09-07 14:07:42 INFO  MyApp - Entering APPLICATION.\n2000-09-07 14:07:43 DEBUG  MyOtherApp - Entering APPLICATION.\n2000-09-07 14:07:45 WARN  MyThirdApp - Entering APPLICATION."
      @indy = Indy.search(logcontent)
    end

    context 'per line results' do

      it "should contain an array of Enumerables" do
        @indy.for(:all).first.should be_kind_of(Enumerable)
      end

      it "should provide attribute readers for each field" do
        line1, line2, line3 = @indy.for(:all)
        line1.time.should == '2000-09-07 14:07:42'
        line1.severity.should == 'INFO'
        line1.application.should == 'MyApp'
        line1.message.should == 'Entering APPLICATION.'
        line2.application.should == 'MyOtherApp'
        line3.application.should == 'MyThirdApp'
      end

    end
  end


end
