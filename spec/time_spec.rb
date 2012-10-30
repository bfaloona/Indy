require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy/time")

describe Indy::Time do

  context 'class method' do

    context 'parse_date' do

      it 'should parse a bare date string' do
        Indy::Time.parse_date('2012-10-10 10:10:10').class.should == Time
      end
      it 'should return a passed Time object' do
        time = Time.now
        Indy::Time.parse_date(time).should === time
      end

      it 'should return a passed DateTime object' do
        time = DateTime.now
        Indy::Time.parse_date(time).should === time
      end

      it "should parse a US style date" do
        time = Indy::Time.parse_date('01-13-2002','%m-%d-%Y')
        time.class.should == DateTime
        time.day.should == 13
      end

    end

    context 'forever' do

      it 'should respond_to' do
        Indy::Time.should respond_to(:forever)
      end

    end

    context 'forever_ago' do

      it 'should respond_to' do
        Indy::Time.should respond_to(:forever_ago)
      end

    end

    context 'inside_time_window?' do

      it 'should respond_to' do
        Indy::Time.should respond_to(:inside_time_window?)
      end

    end

  end

end
