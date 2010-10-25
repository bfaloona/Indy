require 'lib/indy.rb'

describe Result do

  before(:each) do
    @result = Result.new("string","time","severity","application","message")
  end

  [:time, :severity, :application, :message].each do |method|
    it "should have the method '#{method}'" do
      @result.should respond_to(method)
    end
  end

end

