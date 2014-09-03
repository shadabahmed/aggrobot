module Aggrobot
  module QueryPlanner
    module ParametersValidator
      def validate_and_extract_relation(collection)
        if !collection.is_a?(ActiveRecord::Relation) && (collection < ActiveRecord::Base rescue false)
          collection.unscoped
        elsif collection.is_a?(ActiveRecord::Relation)
          collection
        else
          raise ArgumentError.new 'Only ActiveRecord Models and Relations can be used in Aggrobot'
        end
      end

      def validate_options(opts, required_parameters, optional_parameters)
        params = opts.keys
        # raise errors for required parameters
        raise_opts_error(opts, required_parameters, optional_parameters) unless (required_parameters - params).empty?
        # raise errors if any extra arguments given
        raise_opts_error(opts, required_parameters, optional_parameters) unless (params - required_parameters - optional_parameters).empty?
      end

      private

      def raise_opts_error(opts, required_parameters, optional_parameters)
        raise ArgumentError, <<-ERR
          Wrong arguments given - #{opts}
          Required parameters are #{required_parameters}
          Optional parameters are #{optional_parameters}
        ERR
      end
    end
  end
end