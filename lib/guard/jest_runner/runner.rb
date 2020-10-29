# frozen_string_literal: true

require 'json'
require 'open3'

module Guard
  class JestRunner
    # This class runs `jest` command, retrieves result and notifies.
    # An instance of this class is intended to invoke `jest` only once in its lifetime.
    class Runner
      def initialize(options)
        @options = options
      end

      attr_reader :options

      def run(paths)
        paths = options[:default_paths] unless paths

        run_passed = run_for_check(paths)

        case options[:notification]
        when :failed
          notify(run_passed) unless run_passed
        when true
          notify(run_passed)
        end

        case options[:print_result]
        when :failed
          puts @check_stderr unless run_passed
        when true
          puts @check_stderr
        end

        run_passed
      end

      def failed_paths
        result[:testResults].select { |f| f[:status] == "failed" }.map { |f| f[:name] }.uniq
      end

      private

      attr_accessor :check_stdout, :check_stderr

      def run_for_check(paths)
        command = command_for_check(paths)
        (stdout, stderr, status) = Open3.capture3(*command)
        @check_stdout = stdout
        @check_stderr = stderr
        status.success?
      rescue SystemCallError => e
        fail "The jest command failed with #{e.message}: `#{command}`"
      end

      def command_for_check(paths)
        command = [options[:command]]

        command.concat(args_specified_by_user)
        command.concat(['--json', '--colors', "--outputFile=#{json_file_path}"])
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
      rescue JSON::ParserError
        fail "jest JSON output could not be parsed. Output from jest was:\n#{check_stderr}\n#{check_stdout}"
      end

      def notify(run_passed)
        image = run_passed ? :success : :failed
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
