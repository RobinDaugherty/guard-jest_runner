# frozen_string_literal: true

module Guard
  # A workaround for some superclass BS
  # where Jest < Guard has to exist?
  module JestRunnerVersion
    # http://semver.org/
    MAJOR = 1
    MINOR = 0
    PATCH = 0

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
