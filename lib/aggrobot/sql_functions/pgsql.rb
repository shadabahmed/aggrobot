module Aggrobot
  class SQLFunctions
    module PgSQL

      # returns ROUNDED average of attr, with precision(ROUNDING DIGITS)
      def avg(attr, rounding = SQLFunctions.precision)
        "ROUND(AVG(#{attr})::numeric, #{rounding})"
      end

      alias average avg

      # returns percentage based on ROUND SQL function, with precision(ROUNDING DIGITS)
      def percent(total, attr = count, rounding = SQLFunctions.precision)
        total == 0 ? "0" : "ROUND(((#{attr}*100.0))::numeric/#{total}, #{rounding})"
      end

      # returns ROUND of multipliers, with precision(self.precision)
      def multiply(attr, multiplier, rounding = SQLFunctions.precision)
        "ROUND((#{attr}*#{multiplier})::numeric, #{rounding})"
      end

      # returns ROUND of attr/divider, with precision(self.precision)
      def divide(attr, divider, rounding = SQLFunctions.precision)
        "ROUND((#{attr}/#{divider})::numeric, #{rounding})"
      end

    end
  end
end