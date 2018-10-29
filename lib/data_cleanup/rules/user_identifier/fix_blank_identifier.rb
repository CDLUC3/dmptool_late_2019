# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on UserIdentifier
    module UserIdentifier
      class FixBlankIdentifier < Rules::Base

        def description
          "Fix UserIdentifier records with no Identifier"
        end

        def call
          ids = ::UserIdentifier.where(identifier: [nil, ""]).ids
          log("Destroying UserIdentifier where identifier is empty for ids: #{ids} (no user)")
          ::UserIdentifier.destroy(ids)
        end
      end
    end
  end
end
