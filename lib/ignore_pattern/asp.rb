# frozen_string_literal: true

module IgnorePattern
  # ASP.NET
  module ASP
    def ignore_pattern
      /\A*.(aspx|asp|cs|dll|ascx)\z/i
    end
  end
end
