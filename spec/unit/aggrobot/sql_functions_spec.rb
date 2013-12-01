require 'spec_helper'
require 'aggrobot/sql_functions'

module Aggrobot

  describe SqlFunctions do
    before do
      module SqlFunctions
        ROUNDING_DIGITS = 2
      end
    end

    describe '.sql_attr' do
      it 'returns an escaped sql attribute' do
        expect(SqlFunctions.desc('attr')).to eq 'attr desc'
      end
    end

    describe '.count' do
      it 'get SQL Sum' do
        expect(SqlFunctions.count('attr')).to eq 'COUNT(attr)'
      end
    end

    describe '.unique_count' do
      it 'gets distinct COUNT' do
        expect(SqlFunctions.unique_count('attr')).to eq 'COUNT(DISTINCT attr)'
      end
    end

    describe '.max' do
      it 'gets max' do
        expect(SqlFunctions.max('attr')).to eq 'MAX(attr)'
      end
    end

    describe '.max' do
      it 'gets min' do
        expect(SqlFunctions.min('attr')).to eq 'MIN(attr)'
      end
    end

    describe '.sum' do
      it 'gets sum' do
        expect(SqlFunctions.sum('attr')).to eq 'SUM(attr)'
      end
    end

    describe '.avg' do
      it 'gets avg' do
        expect(SqlFunctions.avg('attr')).to eq "ROUND(AVG(attr), #{SqlFunctions::ROUNDING_DIGITS})"
      end
    end

    describe '.group_collect' do
      it 'does group concat' do
        expect(SqlFunctions.group_collect('attr')).to eq 'GROUP_CONCAT(DISTINCT attr)'
      end
    end

    describe '.percent' do
      it 'calculate percent' do
        expect(SqlFunctions.percent('attr', 100)).to eq "ROUND((100*100.0)/attr, #{SqlFunctions::ROUNDING_DIGITS})"
      end

      it 'calculate percent with default params' do
        expect(SqlFunctions.percent('attr')).to eq "ROUND((COUNT(*)*100.0)/attr, #{SqlFunctions::ROUNDING_DIGITS})"
      end
    end

    describe '.mysql' do
      it 'multiplies' do
        expect(SqlFunctions.multiply('attr', 100, 2)).to eq 'ROUND(attr*100, 2)'
      end
    end

    describe '.divide' do
      it 'divides' do
        expect(SqlFunctions.divide('attr', 100, 2)).to eq 'ROUND(attr/100, 2)'
      end
    end

  end
end