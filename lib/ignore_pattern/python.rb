# frozen_string_literal: true

module IgnorePattern
  # Python
  module Python
    def ignore_pattern
      /\A*.(py|pyc)\z/i
    end
  end
end
