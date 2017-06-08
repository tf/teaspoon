module Teaspoon
  module Formatter
    module ReportModule
      RED = 31
      GREEN = 32
      YELLOW = 33
      CYAN = 36

      def log_error(result)
        log_line(result.message, RED)
        (result.trace || []).each do |trace|
          function = trace["function"].present? ? " -- #{trace['function']}" : ""
          log_line("  # #{filename(trace['file'])}:#{trace['line']}#{function}", CYAN)
        end
        log_line
      end

      alias_method :log_exception, :log_error

      def log_result(result)
        log_information
        log_stats(result)
        log_failed_examples
      end

      def log_coverage(message)
        log_line("\n#{message}")
      end

      def log_threshold_failure(message)
        log_line("\n#{message}\n", RED)
      end

      private

      def log_information
        log_pending if pendings.size > 0
        log_failures if failures.size > 0
      end

      def log_pending
        log_line("Pending:")
        pendings.each do |result|
          log_line("  #{result.description}", YELLOW)
          log_line("    # Not yet implemented\n", CYAN)
        end
      end

      def log_failures
        log_line("Failures:\n")
        failures.each_with_index do |failure, index|
          log_line("  #{index + 1}) #{failure.description}")
          log_line("     Failure/Error: #{failure.message}", RED)

          failure.trace.split("\n").map do |line|
            if (line.match(/mocha/) ||
                line.match(/chai/))
              log_line('       in ' + make_readable(line))
            else
              log_line('       in ' + make_readable(line), YELLOW)
            end
          end
          log_line
        end
      end

      def log_stats(result)
        log_line("Finished in #{result.elapsed} seconds")
        stats = "#{pluralize('example', run_count)}, #{pluralize('failure', failures.size)}"
        stats << ", #{pendings.size} pending" if pendings.size > 0
        log_line(stats, stats_color)
      end

      def log_failed_examples
        return if failures.size == 0
        log_line
        log_line("Failed examples:\n")
        failures.each do |failure|
          log_line("teaspoon -s #{@suite_name} --filter=\"#{failure.link}\"", RED)
        end
      end

      def stats_color
        failures.size > 0 ? RED : pendings.size > 0 ? YELLOW : GREEN
      end

      private

      def make_readable(line)
        line.sub(/http:\/\/(\d+\.){3}\d+:\d+\//, '')
          .sub(/\.self/, '')
          .sub(/-[0-9a-f]+/, '')
          .sub(/\?body=1\?body=\d+/, '')
          .sub(/:\d+$/, '')
      end
    end
  end
end
