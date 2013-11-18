require 'spec_helper'

module Aggrobot
  module QueryPlanner
    describe GroupLimitQueryPlanner do
      let(:collection) { double }
      let(:group) { 'group_col' }

      context 'initialization' do
        before do
          GroupLimitQueryPlanner.any_instance.stub(:process_top_groups_options)
        end
        it 'requires explicit parameters' do
          expect { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2) }.to raise_error
          expect { GroupLimitQueryPlanner.new(collection, group, :sort_by => 2) }.to raise_error
          expect { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2, :sort_by => 2) }.to_not raise_error
        end
      end

      describe '#sub_query' do

        context 'with only default options' do
          before do
            should_receive_queries(collection, :group => group, :order => 'order_col desc',
                                   :limit => 2, :pluck => group).and_return(['group1', 'group2'])
          end
          subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2,
                                                               :sort_by => :order_col, :other_group => 'others') }
          context 'for one of the top groups' do
            it 'gives query with only that group in condition' do
              should_receive_queries(collection, :where => {'group_col' => 'group1'}).and_return(:sub_query1)
              expect(query_planner.sub_query('group1')).to eq :sub_query1
            end
          end

          context 'for others group' do
            it 'gives query with only that group in condition' do
              should_receive_queries(collection, :where => nil, not: {'group_col' => ['group1', 'group2']}).and_return(:sub_query_other)
              expect(query_planner.sub_query('others')).to eq :sub_query_other
            end
          end
        end

        context 'with always include option' do
          before do
            should_receive_queries(collection, :group => group, :order => 'order_col desc',
                                   :limit => 2, :pluck => group).and_return(['group1', 'group2'])
          end
          subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2,
                                                               :sort_by => :order_col, :other_group => 'others', :always_include => 'always') }
          context 'for one of the top groups' do
            it 'gives query with only that group in condition' do
              should_receive_queries(collection, :where => {'group_col' => 'always'}).and_return(:sub_query_always)
              expect(query_planner.sub_query('always')).to eq :sub_query_always
            end
          end
        end

      end

      describe '#query_results' do
        let(:columns) { ['group_col', 'COUNT(*)', 'col1', 'col2'] }
        let(:other_columns) { ["'others'", 'COUNT(*)', 'col1', 'col2'] }
        subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2,
                                                             :sort_by => :order_col, :other_group => 'others') }


        context 'when collection is none' do
          before do
            should_receive_queries(collection, :group => group, :order => 'order_col desc',
                                   :limit => 2, :pluck => group).and_return(['group1', 'group2'])
            query_planner.stub(:collection_is_none? => true)
          end
          it 'returns empty result' do
            expect(query_planner.query_results).to be_empty
          end
        end

        context 'with reverse sort order' do
          let(:conditions) { {'group_col' => ['group2', 'group1']} }
          subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2, :order => 'asc',
                                                               :sort_by => :order_col, :other_group => 'others') }
          before do
            should_receive_queries(collection, :group => group, :order => 'order_col asc',
                                   :limit => 2, :pluck => group).and_return(['group2', 'group1'])
            should_receive_queries(collection, :where => conditions,
                                   :group => group, :pluck => columns).and_return([:group2_results, :group1_results])
            should_receive_queries(collection, :where => nil, :not => conditions,
                                   :group => "'others'", :pluck => other_columns).and_return([:others])
            query_planner.stub(:collection_is_none? => false)
          end

          it 'returns results for reverse order' do
            expect(query_planner.query_results(['col1', 'col2'])).to eq [:group2_results, :group1_results, :others]
          end
        end

        context 'when collection is not none and default sort order' do
          let(:conditions) { {'group_col' => ['group1', 'group2']} }

          before do
            should_receive_queries(collection, :group => group, :order => 'order_col desc',
                                   :limit => 2, :pluck => group).and_return(['group1', 'group2'])
            query_planner.stub(:collection_is_none? => false)
          end

          context 'with default options' do
            it 'returns top group results' do
              should_receive_queries(collection, :group => group, :where => conditions, :pluck => columns).and_return([:group1_results, :group2_results])
              should_receive_queries(collection, :where => nil, :not => conditions,
                                     :group => "'others'", :pluck => other_columns).and_return([:others])
              expect(query_planner.query_results(['col1', 'col2'])).to eq [:group1_results, :group2_results, :others]
            end
          end


          context 'with always_include option added' do
            subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2,
                                                                 :sort_by => :order_col, :always_include => 'always', :other_group => 'others') }
            let(:conditions) { {'group_col' => ['group1', 'always']} }
            before do
              query_planner.stub(:collection_is_none? => false)
            end
            it 'returns top group results inlcuding the always_include group' do
              should_receive_queries(collection, :group => group, :where => conditions, :pluck => columns).and_return([:group1_results, :group2_results])
              should_receive_queries(collection, :where => nil, :not => conditions,
                                     :group => "'others'", :pluck => other_columns).and_return([:others])
              expect(query_planner.query_results(['col1', 'col2'])).to eq [:group1_results, :group2_results, :others]
            end
          end

        end
      end
    end
  end
end