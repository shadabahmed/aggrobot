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

  def avg(attr, rounding = ROUNDING_DIGITS)
    "ROUND(AVG(#{attr}), #{rounding})"
  end

  def group_collect(attr)
    "GROUP_CONCAT(DISTINCT #{attr})"
  end

  def percent(total, attr = count, rounding = ROUNDING_DIGITS)
    total == 0 ? "0" : "ROUND((#{attr}*100.0)/#{total}, #{rounding})"
  end

  def divide(attr, divider, rounding = ROUNDING_DIGITS)
    "ROUND(#{attr}/#{divider}, #{rounding})"
  end

end