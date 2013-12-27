require 'spec_helper'

module Aggrobot
  module QueryPlanner

    describe BucketedGroupsQueryPlanner do

      let(:collection) { double }
      let(:group) { 'group_col' }
      let(:buckets) { [1..2, [3, 4, 5], 8, 9] }
      subject(:query_planner) { BucketedGroupsQueryPlanner.new(collection, group, buckets: buckets) }

      describe '#sub_query' do
        before do
          collection.stub(:where).with('group_col' => 1..2).and_return('collection for 1..2')
          collection.stub(:where).with('group_col' => [3,4,5]).and_return('collection for 3,4,5')
          collection.stub(:where).with('group_col' => 8).and_return('collection for 8')
          collection.stub(:where).with('group_col' => 9).and_return('collection for 9')
        end

        it 'returns the correct subquery' do
          expect(query_planner.sub_query((1..2).to_s)).to eq 'collection for 1..2'
          expect(query_planner.sub_query([3,4,5].to_s)).to eq 'collection for 3,4,5'
          expect(query_planner.sub_query(8.to_s)).to eq 'collection for 8'
          expect(query_planner.sub_query(9.to_s)).to eq 'collection for 9'
        end
      end

      describe '#query_results' do
        let(:bucketed_relation) { double }
        before do
          collection.stub(:where).and_return(bucketed_relation)
        end

        context 'collection is none' do
          before do
            query_planner.stub(:collection_is_none? => true, :empty_default_groups => [])
          end
          it 'returns empty result set' do
            expect(query_planner.query_results).to be_empty
          end
        end

        context 'collection is not none' do
          before do
            query_planner.stub(:collection_is_none? => false)
            should_receive_queries(bucketed_relation, :group => SqlFunctions.sanitize((1..2).to_s), limit: 1,
                pluck: [SqlFunctions.sanitize((1..2).to_s), SqlFunctions.count, :col1, :col2])
                .and_return(['results for 1..2'])
            should_receive_queries(bucketed_relation, :group => SqlFunctions.sanitize([3,4,5].to_s), limit: 1,
                                   pluck: [SqlFunctions.sanitize([3,4,5].to_s), SqlFunctions.count, :col1, :col2])
            .and_return(['results for 3,4,5'])
            should_receive_queries(bucketed_relation, :group => SqlFunctions.sanitize(8.to_s), limit: 1,
                                   pluck: [SqlFunctions.sanitize(8.to_s), SqlFunctions.count, :col1, :col2])
            .and_return(['results for 8'])
            should_receive_queries(bucketed_relation, :group => SqlFunctions.sanitize(9.to_s), limit: 1,
                                   pluck: [SqlFunctions.sanitize(9.to_s), SqlFunctions.count, :col1, :col2])
            .and_return(['results for 9'])
          end
          it 'returns empty result set' do
            expect(query_planner.query_results([:col1, :col2])).to eq ["results for 1..2", "results for 3,4,5",
                                                                       "results for 8", "results for 9"]
          end
        end

        context 'empty buckets' do
          before do
            query_planner.stub(:collection_is_none? => false)
            should_receive_queries(bucketed_relation, :group => SqlFunctions.sanitize(:populated.to_s), limit: 1,
                                   pluck: [SqlFunctions.sanitize(:populated.to_s), SqlFunctions.count, :col1, :col2])
            .and_return(['results for populated group'])

            should_receive_queries(bucketed_relation, :group => SqlFunctions.sanitize(:empty.to_s), limit: 1,
                                   pluck: [SqlFunctions.sanitize(:empty.to_s), SqlFunctions.count, :col1, :col2])
            .and_return([])
            bucketed_relation.stub(:none)
          end
          context 'without keep_empty option' do
            subject(:query_planner) { BucketedGroupsQueryPlanner.new(collection, group, buckets: [:populated, :empty]) }
            it 'returns only populated result set' do
              expect(query_planner.query_results([:col1, :col2])).to eq ["results for populated group"]
            end
          end

          context 'with keep_empty option' do
            subject(:query_planner) { BucketedGroupsQueryPlanner.new(collection, group, buckets: [:populated, :empty], keep_empty: true) }
            it 'returns both empty and populated result sets' do
              expect(query_planner.query_results([:col1, :col2])).to eq ["results for populated group", ["empty", 0]]
            end
          end
        end
      end

    end
  end
end