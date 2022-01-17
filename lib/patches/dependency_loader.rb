# frozen_string_literal: true

require "faraday"

# Reintroduce the dependency loader, dropped from Faraday v2.0 and above,
# but frustratingly required by many of the new adapters.

unless defined?(Faraday::DependencyLoader) && defined?(Faraday::Adapter)

  module Faraday
    # DependencyLoader helps Faraday adapters and middleware load dependencies.
    module DependencyLoader
      attr_reader :load_error

      # Executes a block which should try to require and reference dependent
      # libraries
      def dependency(lib = nil)
        lib ? require(lib) : yield
      rescue LoadError, NameError => e
        self.load_error = e
      end

      def new(*)
        unless loaded?
          raise "missing dependency for #{self}: #{load_error.message}"
        end

        super
      end

      def loaded?
        load_error.nil?
      end

      def inherited(subclass)
        super
        subclass.send(:load_error=, load_error)
      end

      private

      attr_writer :load_error
    end
  end

  Faraday::Adapter.class.include Faraday::DependencyLoader
end
