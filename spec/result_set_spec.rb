require "#{File.dirname(__FILE__)}/helper"

describe ResultSet do

  it "should be Enumerable" do
    ResultSet.new.should be_kind_of(Enumerable)
  end
  
end