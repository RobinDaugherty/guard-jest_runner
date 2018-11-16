# frozen_string_literal: true

require 'json'

module Guard
  class Jest
    # This class runs `jest` command, retrieves result and notifies.
    # An instance of this class is intended to invoke `jest` only once in its lifetime.
    class Runner
      def initialize(options)
        @options = options
      end

      attr_reader :options

      def run(paths)
        paths = options[:default_paths] unless paths

        command = command_for_check(paths)
        passed = system(*command)
        case options[:notification]
        when :failed
          notify(passed) unless passed
        when true
          notify(passed)
        end

        passed
      end

      def command_for_check(paths)
        command = [options[:command]]

        command.concat(args_specified_by_user)
        command.concat(['--json', "--outputFile=#{json_file_path}"])
        command.concat(paths)
      end

      def args_specified_by_user
        @args_specified_by_user ||= begin
          args = options[:cli]
          case args
          when Array    then args
          when String   then args.shellsplit
          when NilClass then []
          else fail ':cli option must be either an array or string'
          end
        end
      end

      def json_file_path
        @json_file_path ||= begin
          json_file.close
          json_file.path
        end
      end

      ##
      # Keep the Tempfile instance around so it isn't garbage-collected and therefore deleted.
      def json_file
        @json_file ||= begin
          # Just generate random tempfile path.
          basename = self.class.name.downcase.gsub('::', '_')
          Tempfile.new(basename)
        end
      end

      def result
        @result ||= begin
          File.open(json_file_path) do |file|
            # Rubinius 2.0.0.rc1 does not support `JSON.load` with 3 args.
            JSON.parse(file.read, symbolize_names: true)
          end
        end
      end

      def notify(passed)
        image = passed ? :success : :failed
        Notifier.notify(summary_text, title: 'Jest results', image: image)
      end

      def summary_text
        summary = {
          tests_run: result[:numTotalTests],
          passed: result[:numPassedTests],
          pending: result[:numPendingTests],
          failed: result[:numFailedTests],
        }

        String.new.tap do |text|
          if summary[:failed] > 0
            text << pluralize(summary[:failed], 'example')
            text << " failed"
            text << " (#{summary[:passed]} passed"
            text << ", #{summary[:pending]} pending" if summary[:pending] > 0
            text << ")."
          else
            text << "#{summary[:passed]} passed"
            text << " (#{summary[:pending]} pending)" if summary[:pending] > 0
            text << "."
          end
        end
      end

      def failed_paths
        result[:testResults].select { |f| f[:status] == "failed" }.map { |f| f[:name] }.uniq
      end

      def pluralize(number, thing, options = {})
        text = String.new

        if number == 0 && options[:no_for_zero]
          text = 'no'
        else
          text << number.to_s
        end

        text << " #{thing}"
        text << 's' unless number == 1

        text
      end
    end
  end
end
