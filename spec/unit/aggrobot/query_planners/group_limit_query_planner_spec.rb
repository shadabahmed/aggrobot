require 'spec_helper'

module Aggrobot
  module QueryPlanner
    describe GroupLimitQueryPlanner do

      before :all do
        FactoryRobot.start(:users) do
          count 400
          name  4 => 'Tom', 7 => 'Hardy', 9 => 'Dark', 10 => 'Knight'
          age   4 => 20, 7 => 40, 9 => 60, 10 => 80
          score 4 => 100, 7 => 200, 9 => 300, 10 => 400
        end
      end

      context 'initialization' do
        before do
          GroupLimitQueryPlanner.any_instance.stub(:process_top_groups_options)
        end
        it 'requires explicit parameters' do
          expect { GroupLimitQueryPlanner.new(User, :name, :limit_to => 2) }.to raise_error(ArgumentError)
          expect { GroupLimitQueryPlanner.new(User, :name, :sort_by => 2) }.to raise_error(ArgumentError)
          expect { GroupLimitQueryPlanner.new('User', :name, :limit_to => 2, :sort_by => 2) }.to raise_error(ArgumentError)
          expect { GroupLimitQueryPlanner.new(User, :name, :limit_to => 2, :sort_by => 2) }.to_not raise_error
        end
      end

      describe '#sub_query' do

        context 'with only default options' do
          let(:group_query){ 'SELECT "users".* FROM "users"  WHERE "users"."name" = \'Tom\'' }
          let(:other_group_query) { 'SELECT "users".* FROM "users"  WHERE ("users"."name" NOT IN (\'Tom\', \'Hardy\'))' }
          subject(:query_planner) { GroupLimitQueryPlanner.new(User, 'name', :limit_to => 2,
                                                               :sort_by => SQLFunctions.count, :other_group => 'others') }
          context 'for one of the top groups' do
            it 'gives query with only that group in condition' do
              expect(query_planner.sub_query('Tom').to_sql).to eq group_query
            end
          end

          context 'for others group' do
            it 'gives query with only that group in condition' do
              expect(query_planner.sub_query('others').to_sql).to eq other_group_query
            end
          end
        end

        context 'with always include option' do
          let(:group_query){ 'SELECT "users".* FROM "users"  WHERE "users"."name" = \'Knight\'' }
          let(:other_group_query) { 'SELECT "users".* FROM "users"  WHERE ("users"."name" NOT IN (\'Tom\', \'Knight\'))' }
          subject(:query_planner) { GroupLimitQueryPlanner.new(User, :name, :limit_to => 2,
                                                               :sort_by => SQLFunctions.count, :other_group => 'others', :always_include => 'Knight') }
          context 'for one of the top groups' do
            it 'gives query with only that group in condition' do
              expect(query_planner.sub_query('Knight').to_sql).to eq group_query
            end
          end

          context 'for others group' do
            it 'gives query with only that group in condition' do
              expect(query_planner.sub_query('others').to_sql).to eq other_group_query
            end
          end
        end

        context 'group on multiple coulmns' do
          let(:group_query){ 'SELECT "users".* FROM "users"  WHERE "users"."name" = \'Knight\' AND "users"."age" = 80' }
          let(:other_group_query) { 'SELECT "users".* FROM "users"  WHERE ("users"."name" NOT IN (\'Tom\', \'Hardy\')) AND ("users"."age" NOT IN (20, 40))' }
          subject(:query_planner) { GroupLimitQueryPlanner.new(User, [:name, :age], :limit_to => 2,
                                                               :sort_by => SQLFunctions.count, :other_group => 'others') }
          context 'for one of the top groups' do
            it 'gives query with only that group in condition' do
              expect(query_planner.sub_query(['Knight', 80]).to_sql).to eq group_query
            end
          end

          context 'for others group' do
            it 'gives query with only that group in condition' do
              expect(query_planner.sub_query('others').to_sql).to eq other_group_query
            end
          end
        end
      end

      describe '#query_results' do
        subject(:query_planner) { GroupLimitQueryPlanner.new(User, 'name', :limit_to => 2,
                                                             :sort_by => SQLFunctions.count, :other_group => 'others') }
        context 'when collection is none' do
          subject(:query_planner) { GroupLimitQueryPlanner.new(User.unscoped.none, :name, :limit_to => 2,
                                                               :sort_by => SQLFunctions.count, :other_group => 'others') }
          it 'returns empty result' do
            expect(query_planner.query_results).to be_empty
          end
        end

        context 'with reverse sort order' do
          let(:reverse_order_groups){ [["Dark", 80, 4800, 300.0], ["Knight", 40, 3200, 400.0], ["others", 280, 8000, 142.86]] }
          subject(:query_planner) { GroupLimitQueryPlanner.new(User, :name, :limit_to => 2, :order => 'asc',
                                                               :sort_by => SQLFunctions.count, :other_group => 'others') }
          it 'returns results for reverse order' do
            expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq reverse_order_groups
          end
        end

        context 'when collection is not none and default sort order' do
          let(:results) { [['Hardy', 120, 4800, 200.0], ['Tom', 160, 3200, 100.0], ['others', 120, 8000, 333.33]] }
          context 'with default options' do
            it 'returns top group results' do
              expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq results
            end
          end

          context 'with always_include option added' do
            let(:results){ [["Knight", 40, 3200, 400.0], ["Tom", 160, 3200, 100.0], ["others", 200, 9600, 240.0]] }
            subject(:query_planner) { GroupLimitQueryPlanner.new(User, :name, :limit_to => 2,
                                                                 :sort_by => SQLFunctions.count, :always_include => 'Knight', :other_group => 'others') }
            it 'returns top group results inlcuding the always_include group' do
              expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq results
            end
          end

          context 'with grouping on multiple columns' do
            let(:results){ [[["Dark", 60], 80, 4800, 300.0], [["Tom", 20], 160, 3200, 100.0], ["others", 80, 160, 8000, 250.0]] }
            subject(:query_planner) { GroupLimitQueryPlanner.new(User, [:name, :age], :limit_to => 2,
                                                                 :sort_by => SQLFunctions.count, :other_group => 'others', :always_include => ['Dark', 60]) }
            it 'returns top group results inlcuding the always_include group' do
              expect(query_planner.query_results([SQLFunctions.sum(:age), SQLFunctions.average(:score)])).to eq results
            end
          end

        end
      end
    end
  end
end