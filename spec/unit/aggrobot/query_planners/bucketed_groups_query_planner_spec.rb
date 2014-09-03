require 'spec_helper'

module Aggrobot
  module QueryPlanner

    describe BucketedGroupsQueryPlanner do
      before :all do
        FactoryRobot.start(:users) do
          count 400
          name  4 => 'Tom', 7 => 'Hardy', 9 => 'Dark', 10 => 'Knight'
          age   4 => 20, 7 => 40, 9 => 60, 10 => 80
          score 4 => 100, 7 => 200, 9 => 300, 10 => 400
        end
      end


      let(:buckets) { [100, 200..299, 300..399, 400] }
      subject(:query_planner) { BucketedGroupsQueryPlanner.new(User, :score, buckets: buckets) }

      context 'initialization' do
        it 'requires explicit parameters' do
          expect { BucketedGroupsQueryPlanner.new(User, :name) }.to raise_error(ArgumentError)
          expect { BucketedGroupsQueryPlanner.new(User, :name, :keep_empty => true) }.to raise_error(ArgumentError)
          expect { BucketedGroupsQueryPlanner.new('User', :name, :buckets => buckets, :keep_empty => true) }.to raise_error(ArgumentError)
          expect { BucketedGroupsQueryPlanner.new(User, :name, :buckets => buckets, :keep_empty => true) }.to_not raise_error
        end
      end

      describe '#sub_query' do
        let(:sub_query) { 'SELECT "users".* FROM "users"  WHERE "users"."score" = 100'}
        it 'returns the correct subquery' do
          expect(query_planner.sub_query(100).to_sql).to eq sub_query
        end

        context 'group on multiple columns' do
          let(:buckets) { [['Tim',1..2], ['Black', [3, 4, 5]], ['Knight',[8, 9]]] }
          subject(:query_planner) { BucketedGroupsQueryPlanner.new(User, [:name, :score], buckets: buckets) }
          let(:sub_query) { 'SELECT "users".* FROM "users"  WHERE "users"."name" = \'Tim\' AND ("users"."score" BETWEEN 1 AND 2)'}
          it 'returns the correct subquery' do
            expect(query_planner.sub_query(['Tim',1..2]).to_sql).to eq sub_query
          end
        end
      end

      describe '#query_results' do

        context 'collection is none' do
          subject(:query_planner) { BucketedGroupsQueryPlanner.new(User.unscoped.none, :score, buckets: buckets) }
          it 'returns empty result set' do
            expect(query_planner.query_results).to be_empty
          end
        end

        context 'collection is not none' do
          let(:results) { [[100, 160, 3200, 100.0], [200..299, 120, 4800, 200.0], [300..399, 80, 4800, 300.0], [400, 40, 3200, 400.0]] }
          it 'returns correct result set' do
            expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq results
          end
        end

        context 'empty buckets' do
          context 'without keep_empty option' do
            let(:results){ [['Knight', 40, 3200, 400.0]] }
            subject(:query_planner) { BucketedGroupsQueryPlanner.new(User, :name, buckets: ['Batman', 'Knight']) }
            it 'returns only populated result set' do
              expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq results
            end
          end

          context 'with keep_empty option' do
            let(:results){ [['Batman', 0], ['Knight', 40, 3200, 400.0]] }
            subject(:query_planner) { BucketedGroupsQueryPlanner.new(User, :name, buckets: ['Batman', 'Knight'], keep_empty: true) }
            it 'returns only populated result set' do
              expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq results
            end
          end

        end
      end

    end
  end
end