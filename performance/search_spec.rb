require "#{File.dirname(__FILE__)}/helper"

describe "Search Performance" do

  subject { """
  2000-09-07 14:07:41 INFO  MyApp - Entering application.
  2000-09-07 14:07:42 DEBUG MyApp - Focusing application.
  2000-09-07 14:07:43 DEBUG MyApp - Blurring application.
  2000-09-07 14:07:44 WARN  MyApp - Low on Memory.
  2000-09-07 14:07:45 ERROR MyApp - Out of Memory.
  2000-09-07 14:07:46 INFO  MyApp - Exiting application.
  """ }
  
  context :_search do
    
    profile :file => STDOUT, :printer => :flat  do
      it "should perform well for the data set" do
        
        Indy.search(subject).for(:severity => 'INFO')
        
      end
    end
    
  end
  
end
