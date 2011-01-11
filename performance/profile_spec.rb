require "#{File.dirname(__FILE__)}/helper"

describe "Search Performance" do


  context "with a small data set" do

    longer_subject = [
      "2000-09-07 14:07:41 INFO  MyApp - Entering application.\n",
      "2000-09-07 14:07:42 DEBUG MyApp - Focusing application.\n",
      "2000-09-07 14:07:43 DEBUG MyApp - Blurring application.\n",
      "2000-09-07 14:07:44 WARN  MyApp - Low on Memory.\n",
      "2000-09-07 14:07:45 ERROR MyApp - Out of Memory.\n",
      "2000-09-07 14:07:46 INFO  MyApp - Exiting application.\n"
    ].collect {|line| line * 70 }.join

    profile :file => STDOUT, :printer => :flat, :min_percent => 1  do

      it "should perform well using #for(:all)" do
        Indy.search(longer_subject.dup).for(:all)
      end

      it "should perform well using #for(:field => 'value')" do
        Indy.search(longer_subject.dup).for(:severity => 'INFO')
      end

      it "should perform well using #time()" do
        Indy.search(longer_subject.dup).after(:time => "2000-09-07 14:07:45").for(:all)
      end

    end

  end

end
