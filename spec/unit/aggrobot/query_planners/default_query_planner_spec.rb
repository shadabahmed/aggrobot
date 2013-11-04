require 'spec_helper'

module Aggrobot
  describe DefaultQueryPlanner do
    let(:collection) { double }
    let(:group) { 'group_col' }
    subject(:query_planner) { DefaultQueryPlanner.new(collection, group) }

    describe '#sub_query' do
      context 'when group was specified' do
        before do
          collection.should_receive(:where).with('group_col' => 'group').and_return('collection')
        end
        it 'returns the correct subquery' do
          expect(query_planner.sub_query('group')).to eq 'collection'
        end
      end

      context 'when default group' do
        let(:query_planner) { DefaultQueryPlanner.new(collection, DEFAULT_GROUP_BY) }
        it 'returns the correct subquery' do
          expect(query_planner.sub_query('group')).to eq collection
        end
      end
    end

    describe '#query_results' do
      context 'collection is none' do
        before{ query_planner.stub(:collection_is_none? => true) }
        it { expect(query_planner.query_results).to be_empty }
      end

      context 'collection is not none' do
        let(:grouped_relation) { double }
        before do
          query_planner.stub(:collection_is_none? => false)
          SqlAttributes.stub(:count => 'count')
          collection.should_receive(:group).with('group_col').and_return(grouped_relation)
          grouped_relation.should_receive(:pluck)
                          .with('group_col', 'count', 'extra_col1', 'extra_col2')
                          .and_return(:results)
        end
        it 'returns results for columns' do
          expect(query_planner.query_results(['extra_col1', 'extra_col2'])).to eq :results
        end
      end

    end
  end
end
