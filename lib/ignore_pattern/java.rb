# frozen_string_literal: true

module IgnorePattern
  # Java
  module JAVA
    def ignore_pattern
      /\A*.(jspf?|jar|class|war)\z/i
    end
  end
end
