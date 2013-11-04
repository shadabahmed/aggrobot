require 'spec_helper'

module Aggrobot
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
          should_receive_queries(collection, ['group1', 'group2'], :group => group, :order => 'order_col desc',
                                 :limit => 2, :pluck => group)
        end
        subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2,
                                                             :sort_by => :order_col, :other_group => 'others') }
        context 'for one of the top groups' do
          it 'gives query with only that group in condition' do
            should_receive_queries(collection, :sub_query1, :where => {'group_col' => 'group1'})
            expect(query_planner.sub_query('group1')).to eq :sub_query1
          end
        end

        context 'for others group' do
          it 'gives query with only that group in condition' do
            should_receive_queries(collection, :sub_query_other, :where => nil, not: {'group_col' => ['group1', 'group2']})
            expect(query_planner.sub_query('others')).to eq :sub_query_other
          end
        end
      end

      context 'reverse sort order' do
        before do
          should_receive_queries(collection, ['group2', 'group1'], :group => group, :order => 'order_col asc',
                                 :limit => 2, :pluck => group)
        end
        subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2, :order => 'asc',
                                                             :sort_by => :order_col, :other_group => 'others') }
        context 'for one of the top groups' do
          it 'gives query with only that group in condition' do
            should_receive_queries(collection, :sub_query1, :where => {group => 'group2'})
            expect(query_planner.sub_query('group2')).to eq :sub_query1
          end
        end
      end

      context 'with always include option' do
        before do
          should_receive_queries(collection, ['group1', 'group2'], :group => group, :order => 'order_col desc',
                                 :limit => 2, :pluck => group)
        end
        subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2,
                                                             :sort_by => :order_col, :other_group => 'others', :always_include => 'always') }
        context 'for one of the top groups' do
          it 'gives query with only that group in condition' do
            should_receive_queries(collection, :sub_query_always, :where => {'group_col' => 'always'})
            expect(query_planner.sub_query('always')).to eq :sub_query_always
          end
        end
      end

    end

    describe '#query_results' do
      let(:columns) { ['group_col', 'COUNT(*)', 'col1', 'col2'] }
      let(:other_columns) { ['others', 'COUNT(*)', 'col1', 'col2'] }
      subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2,
                                                           :sort_by => :order_col, :other_group => 'others') }


      context 'when collection is none' do
        before do
          should_receive_queries(collection, ['group1', 'group2'], :group => group, :order => 'order_col desc',
                                 :limit => 2, :pluck => group)
          query_planner.stub(:collection_is_none? => true)
        end
        it 'returns empty result' do
          expect(query_planner.query_results).to be_empty
        end
      end

      context 'when collection is not none' do
        let(:conditions) { {'group_col' => ['group1', 'group2']} }

        before do
          should_receive_queries(collection, ['group1', 'group2'], :group => group, :order => 'order_col desc',
                                 :limit => 2, :pluck => group)
          query_planner.stub(:collection_is_none? => false)
          ActiveRecord::Base.stub(:sanitize) { |x| x }
        end

        context 'with default options' do
          it 'returns top group results' do
            should_receive_queries(collection, [:results], :group => group, :where => conditions, :pluck => columns)
            should_receive_queries(collection, [:others], :where => nil, :not => conditions,
                                   :group => 'others', :pluck => other_columns)
            expect(query_planner.query_results(['col1', 'col2'])).to eq [:results, :others]
          end
        end

        context 'with always_include option added' do
          subject(:query_planner) { GroupLimitQueryPlanner.new(collection, group, :limit_to => 2,
                                                               :sort_by => :order_col, :always_include => 'always', :other_group => 'others') }
          let(:conditions) { {'group_col' => ['group1', 'always']} }
          before do
            query_planner.stub(:collection_is_none? => false)
            ActiveRecord::Base.stub(:sanitize) { |x| x }
          end
          it 'returns top group results' do
            should_receive_queries(collection, [:results], :group => group, :where => conditions, :pluck => columns)
            should_receive_queries(collection, [:others], :where => nil, :not => conditions,
                                   :group => 'others', :pluck => other_columns)
            expect(query_planner.query_results(['col1', 'col2'])).to eq [:results, :others]
          end
        end

      end
    end
  end
end
