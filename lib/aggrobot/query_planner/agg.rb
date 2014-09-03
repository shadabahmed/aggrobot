
route = Route.first
Infinity = (1.0/0)

def los_labels
    ->(label){
      range = label.match(/(?<begin>\-?\d+)?(?<separator>[\-\<])?(?<end>\-?\d+)?/)
      case range[:separator]
      when '<'
        "#{range[:end]}+"
      when '-'
        "#{range[:begin]} to #{range[:end]}"
      else
        label
      end
    }
  end

los_agg = Aggrobot.start(route.passengers) do |attrs|
  hash do
    group_by :length_of_stay, limit_to: 4, sort_by: count, other_group: 'others'
    set advance: :ap, ptype: :pax_type, pct: percent(count, attrs[:count])
    
    each_group do |attrs| 
      attrs
    end
  end
end
