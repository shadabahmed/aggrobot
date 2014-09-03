require 'spec_helper'
require 'aggrobot/sql_functions/common'

module Aggrobot
  describe SQLFunctions do
    before(:all) do
      SQLFunctions.setup(2, SQLFunctions::MYSQL_ADAPTER_NAME)
    end
    subject { SQLFunctions }

    describe '.sql_attr' do
      it 'returns an escaped sql attribute' do
        expect(subject.desc('attr')).to eq 'attr desc'
      end
      it 'returns an escaped sql attribute to order asc' do
        expect(subject.asc('attr')).to eq 'attr asc'
      end
    end

    describe '.count' do
      it 'get SQL Sum' do
        expect(subject.count('attr')).to eq 'COUNT(attr)'
      end
    end

    describe '.unique_count' do
      it 'gets distinct COUNT' do
        expect(subject.unique_count('attr')).to eq 'COUNT(DISTINCT attr)'
      end
    end

    describe '.max' do
      it 'gets max' do
        expect(subject.max('attr')).to eq 'MAX(attr)'
      end
    end

    describe '.max' do
      it 'gets min' do
        expect(subject.min('attr')).to eq 'MIN(attr)'
      end
    end

    describe '.sum' do
      it 'gets sum' do
        expect(subject.sum('attr')).to eq 'SUM(attr)'
      end
    end

    describe '.avg' do
      it 'gets avg' do
        expect(subject.avg('attr')).to eq 'ROUND(AVG(attr), 2)'
      end
    end

    describe '.group_collect' do
      it 'does group concat' do
        expect(subject.group_collect('attr')).to eq 'GROUP_CONCAT(DISTINCT attr)'
      end
    end

    describe '.percent' do
      it 'calculate percent' do
        expect(subject.percent('attr', 100)).to eq 'ROUND((100*100.0)/attr, 2)'
      end

      it 'calculate percent with default params' do
        expect(SQLFunctions.percent('attr')).to eq 'ROUND((COUNT(*)*100.0)/attr, 2)'
      end
    end

    describe '.mysql' do
      it 'multiplies' do
        expect(SQLFunctions.multiply('attr', 100, 2)).to eq 'ROUND(attr*100, 2)'
      end
    end

    describe '.divide' do
      it 'divides' do
        expect(SQLFunctions.divide('attr', 100, 2)).to eq 'ROUND(attr/100, 2)'
      end
    end

  end
end