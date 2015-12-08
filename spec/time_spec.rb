require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy/time")

describe Indy::Time do

  context 'class method' do

    context 'parse_date' do

      it 'should parse a bare date string' do
        expect(Indy::Time.parse_date('2012-10-10 10:10:10').class).to eq(Time)
      end
      it 'should return a passed Time object' do
        time = Time.now
        expect(Indy::Time.parse_date(time)).to be === time
      end

      it 'should return a passed DateTime object' do
        time = DateTime.now
        expect(Indy::Time.parse_date(time)).to be === time
      end

      it "should parse a US style date" do
        time = Indy::Time.parse_date('01-13-2002','%m-%d-%Y')
        expect(time.class).to eq(DateTime)
        expect(time.day).to eq(13)
      end

    end

    context 'forever' do

      it 'should respond_to' do
        expect(Indy::Time).to respond_to(:forever)
      end

    end

    context 'forever_ago' do

      it 'should respond_to' do
        expect(Indy::Time).to respond_to(:forever_ago)
      end

    end

  end
end
