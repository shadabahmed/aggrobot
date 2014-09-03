require 'spec_helper'

module Aggrobot
  module QueryPlanner
    describe DefaultQueryPlanner do
      before :all do
        FactoryRobot.start(:users) do
          count 400
          name  ['Tom', 'Hardy']
          age   [20, 40]
          score [100, 200]
        end
      end

      after :all do
        User.delete_all
      end

      context 'initializing with a non active record object' do
        it 'raises exception' do
          expect{ DefaultQueryPlanner.new('TEST') }.to raise_error(ArgumentError)
        end
      end

      subject(:query_planner) { DefaultQueryPlanner.new(User, 'name') }
      describe '#sub_query' do
        context 'when default group' do
          let(:group_query) { 'SELECT "users".* FROM "users"' }
          subject(:query_planner) { DefaultQueryPlanner.new(User) }
          it 'returns the correct subquery' do
            expect(query_planner.sub_query(DEFAULT_GROUP_BY).to_sql).to eq group_query
          end
        end

        context 'when group was specified' do
          let(:tom_group_query) { 'SELECT "users".* FROM "users"  WHERE "users"."name" = \'Tom\'' }
          let(:hardy_group_query) { 'SELECT "users".* FROM "users"  WHERE "users"."name" = \'Hardy\'' }
          it 'returns the correct subquery' do
            expect(query_planner.sub_query('Tom').to_sql).to eq tom_group_query
            expect(query_planner.sub_query('Hardy').to_sql).to eq hardy_group_query
          end
        end

        context 'when group is an array' do
          subject(:query_planner) { DefaultQueryPlanner.new(User, ['name', 'age']) }
          let(:array_group_query) { 'SELECT "users".* FROM "users"  WHERE "users"."name" = \'Tom\' AND "users"."age" = 20' }
          it 'returns the correct subquery' do
            expect(query_planner.sub_query(['Tom', 20]).to_sql).to eq array_group_query
          end
        end
      end

      describe '#query_results' do
        context 'collection is none' do
          subject(:query_planner) { DefaultQueryPlanner.new(User.none) }
          it { expect(query_planner.query_results).to be_empty }
        end

        context 'collection is not none' do
          let(:group_results){ [['Hardy', 200, 8000, 200.0], ['Tom', 200, 4000, 100.0]] }
          it 'returns results for columns' do
            expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq group_results
          end
        end

        context 'collection is not none' do
          subject(:query_planner) { DefaultQueryPlanner.new(User, ['name', 'age']) }
          let(:group_results){ [[['Hardy', 40], 200, 8000, 200.0], [['Tom', 20], 200, 4000, 100.0]] }
          it 'returns results for columns' do
            expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq group_results
          end
        end

      end
    end
  end
end
