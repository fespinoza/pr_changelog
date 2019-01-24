# frozen_string_literal: true

module PrChangelog
  # Used for the implementation of the exposed executable for this gem
  class CLI
    HELP_TEXT = <<~HELP
      Usage: pr_changelog [options] from_reference to_reference

      [Options]

        -h, --help\tShow this help
        --format FORMAT_NAME\t(default "plain"), options ("pretty", "plain")

      [Examples]

        Listing the changes for the last release (since the previous to the last one)

        $ pr_changelog
    HELP

    class InvalidInputs < StandardError
    end

    class HelpWanted < StandardError
    end

    attr_reader :format, :from_reference, :to_reference


      @format = PrChangelog.config.default_format
      if args.include?('--format')
        next_index = args.index('--format') + 1
        @format = args.delete_at(next_index)
        args.delete('--format')
      end
    def initialize(raw_args, releases = nil)
      raise HelpWanted.new if args.include_flags?('-h', '--help')

      @from_reference, @to_reference = args.last(2)
      @to_reference ||= 'master'

      return if @from_reference && @to_reference

      raise InvalidInputs.new
    end

    def run
      changes = NotReleasedChanges.new(from_reference, to_reference)
      puts "## Changes since #{from_reference} to #{to_reference}\n\n"

      if format == 'pretty'
        puts changes.grouped_formatted_changelog
      else
        puts changes.formatted_changelog
      end
    end
  end
end
