require "#{File.dirname(__FILE__)}/helper"

describe "Search Performance" do


  context "with a 420 line log file" do

    log_content = [
      "2000-09-07 14:07:41 INFO  MyApp - Entering application.\n",
      "2000-09-07 14:07:42 DEBUG MyApp - Focusing application.\n",
      "2000-09-07 14:07:43 DEBUG MyApp - Blurring application.\n",
      "2000-09-07 14:07:44 WARN  MyApp - Low on Memory.\n",
      "2000-09-07 14:07:45 ERROR MyApp - Out of Memory.\n",
      "2000-09-07 14:07:46 INFO  MyApp - Exiting application.\n"
    ].collect {|line| line * 70 }.join

    profile :file => STDOUT, :printer => :flat, :min_percent => 1  do

      it "should profile code using #for(:all)" do
        Indy.search(log_content.dup).for(:all)
      end

      it "should profile code using #for(:field => 'value')" do
        Indy.search(log_content.dup).for(:severity => 'INFO')
      end

      it "should profile code using #time()" do
        Indy.search(log_content.dup).after(:time => "2000-09-07 14:07:45").for(:all)
      end

    end

  end

  context "with a 10000 line log file" do

    large_file = "#{File.dirname(__FILE__)}/large.log"

    profile :file => STDOUT, :printer => :flat, :min_percent => 1  do

      it "should profile code using #for(:all)" do
        Indy.search(large_file).for(:all)
      end

      it "should profile code using #for(:field => 'value')" do
        Indy.search(large_file).for(:severity => 'DEBUG')
      end

      it "should profile code using #time()" do
        Indy.search(large_file).after(:time => "12-29-2010 12:11:33").for(:all)
      end

    end

  end

end
