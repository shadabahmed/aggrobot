module Aggrobot
  class SQLFunctions
    module Common
      delegate :sanitize, to: ActiveRecord::Base
      mattr_accessor :precision

      def desc(attr)
        "#{attr} desc"
      end

      def asc(attr)
        "#{attr} asc"
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
      def avg(attr, rounding = SQLFunctions.precision)
        "ROUND(AVG(#{attr}), #{rounding})"
      end

      alias average avg

      # GROUP_CONCAT: A SQL function which returns a concatenated string
      # group_collect returns concatenated string of distinct attr
      def group_collect(attr)
        "GROUP_CONCAT(DISTINCT #{attr})"
      end

      # returns percentage based on ROUND SQL function, with precision(ROUNDING DIGITS)
      def percent(total, attr = count, rounding = SQLFunctions.precision)
        total == 0 ? "0" : "ROUND((#{attr}*100.0)/#{total}, #{rounding})"
      end

      # returns ROUND of multipliers, with precision(self.precision)
      def multiply(attr, multiplier, rounding = SQLFunctions.precision)
        "ROUND(#{attr}*#{multiplier}, #{rounding})"
      end

      # returns ROUND of attr/divider, with precision(self.precision)
      def divide(attr, divider, rounding = SQLFunctions.precision)
        "ROUND(#{attr}/#{divider}, #{rounding})"
      end

    end
  end
end