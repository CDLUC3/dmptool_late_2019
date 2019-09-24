# frozen_string_literal: true

json.ignore_nil!

# A JSON representation of a Person in the Common Standard format
unless user.name(false) == user.email
  orcid = user.identifier_for(IdentifierScheme.where(name: 'orcid').first)

  json.name user.name(false)
  json.mbox user.email

  if user.org.present?
    json.organizations [user.org] do |org|
      json.partial! 'orgs/rda_common_standard', org: org
    end
  end

  if rel != 'primary_contact'
    json.contributor_type rel

    if orcid.present?
      json.user_ids do
        json.array! 1.times do
          json.category 'orcid'
          json.value orcid.identifier
        end
      end
    end
  else
    if orcid.present?
      json.contact_ids do
        json.array! 1.times do
          json.category 'orcid'
          json.value orcid.identifier
        end
      end
    end
  end
end