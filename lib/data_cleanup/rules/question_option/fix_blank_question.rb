# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank template on Plan
    module QuestionOption
      class FixBlankQuestion < Rules::Base

        def description
          "Fix blank question on QuestionOption"
        end

        def call
          ids = ::QuestionOption.joins("LEFT OUTER JOIN questions ON questions.id = question_options.question_id")
                      .where(questions: { id: nil }).ids
          log("Destroying QuestionOption without Question: #{ids}")
          ::QuestionOption.destroy(ids)
        end
      end
    end
  end
end
