# frozen_string_literal: true

module IgnorePattern
  # No files ignored
  module None
    # Pattern to ignore files during the creation of the fingerprints
    def ignore_pattern
      nil
    end
  end
end
