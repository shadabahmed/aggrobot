require 'spec_helper'

module Aggrobot
  describe SqlAttributes do
    describe '.sql_attr' do
      it 'returns an escaped sql attribute' do
        expect(SqlAttributes.desc('attr')).to eq 'attr desc'
      end
    end

    describe '.count' do
      it 'get SQL Sum' do
        expect(SqlAttributes.count('attr')).to eq 'COUNT(attr)'
      end
    end

    describe '.unique_count' do
      it 'gets distinct COUNT' do
        expect(SqlAttributes.unique_count('attr')).to eq 'COUNT(DISTINCT attr)'
      end
    end

    describe '.max' do
      it 'gets max' do
        expect(SqlAttributes.max('attr')).to eq 'MAX(attr)'
      end
    end

    describe '.max' do
      it 'gets min' do
        expect(SqlAttributes.min('attr')).to eq 'MIN(attr)'
      end
    end

    describe '.sum' do
      it 'gets sum' do
        expect(SqlAttributes.sum('attr')).to eq 'SUM(attr)'
      end
    end

    describe '.avg' do
      it 'gets avg' do
        expect(SqlAttributes.avg('attr')).to eq "ROUND(AVG(attr), #{SqlAttributes::ROUNDING_DIGITS})"
      end
    end

    describe '.group_collect' do
      it 'does group concat' do
        expect(SqlAttributes.group_collect('attr')).to eq 'GROUP_CONCAT(DISTINCT attr)'
      end
    end

    describe '.percent' do
      it 'calculate percent' do
        expect(SqlAttributes.percent('attr', 100)).to eq 'ROUND((attr*100.0)/100, #{SqlAttributes::ROUNDING_DIGITS})'
      end
    end

    describe '.divide' do
      it 'divides' do
        expect(SqlAttributes.divide('attr', 100, 2)).to eq 'ROUND(attr/100, 2)'
      end
    end

  end
end