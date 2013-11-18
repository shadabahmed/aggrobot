module Aggrobot::SqlFunctions

  extend self

  def sanitize(attr)
    "'#{attr}'"
  end

  def desc(attr)
    "#{attr} desc"
  end

  def count(attr = '*')
    "COUNT(#{attr})"
  end

  def unique_count(attr = '*')
    "COUNT(DISTINCT #{attr})"
  end

  def max(attr)
    "MAX(#{attr})"
  end

  def min(attr)
    "MIN(#{attr})"
  end

  def sum(attr = count)
    "SUM(#{attr})"
  end

  def avg(attr)
    "ROUND(AVG(#{attr}), #{ROUNDING_DIGITS})"
  end

  def group_collect(attr)
    "GROUP_CONCAT(DISTINCT #{attr})"
  end

  def percent(attr = count, total)
    total == 0 ? "0" : "ROUND((#{attr}*100.0)/#{total}, #{ROUNDING_DIGITS})"
  end

  def divide(attr, divider, rounding = 3)
    "ROUND(#{attr}/#{divider}, #{rounding})"
  end

end