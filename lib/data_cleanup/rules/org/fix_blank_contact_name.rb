# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix invalid email on Org
    module Org
      class FixBlankContactName < Rules::Base

        def description
          "Fix contact_name on Org"
        end

        def call
          ::Org.update_all("contact_name = TRIM(name)")
          ::Org.where(contact_name: "").update_all(contact_name: nil)
        end
      end
    end
  end
end
