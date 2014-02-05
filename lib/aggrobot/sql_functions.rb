module Aggrobot

  # Collection of methods for SQL functions
  module SqlFunctions

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

    # returns ROUNDED average of attr, with precision(ROUNDING DIGITS)
    def avg(attr, rounding = ROUNDING_DIGITS)
      "ROUND(AVG(#{attr}), #{rounding})"
    end

    # GROUP_CONCAT: A SQL function which returns a concatenated string
    # group_collect returns concatenated string of distinct attr
    def group_collect(attr)
      "GROUP_CONCAT(DISTINCT #{attr})"
    end

    # returns percentage based on ROUND SQL function, with precision(ROUNDING DIGITS)
    def percent(total, attr = count, rounding = ROUNDING_DIGITS)
      total == 0 ? "0" : "ROUND((#{attr}*100.0)/#{total}, #{rounding})"
    end

    # returns ROUND of multipliers, with precision(ROUNDING_DIGITS)
    def multiply(attr, multiplier, rounding = ROUNDING_DIGITS)
      "ROUND(#{attr}*#{multiplier}, #{rounding})"
    end

    # returns ROUND of attr/divider, with precision(ROUNDING_DIGITS)
    def divide(attr, divider, rounding = ROUNDING_DIGITS)
      "ROUND(#{attr}/#{divider}, #{rounding})"
    end

  end
end