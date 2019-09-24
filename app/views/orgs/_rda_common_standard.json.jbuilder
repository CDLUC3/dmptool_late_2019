# frozen_string_literal: true

json.ignore_nil!

# A JSON representation of an Organization in the Common Standard format
json.name org.name

ror_scheme = IdentifierScheme.where(name: 'ror').first

if ror_scheme.present?
  ror_id = org.org_identifiers.select { |id| id.identifier_scheme_id == ror_scheme.id }.first

  if ror_id.present? && ror_id.identifier.present?
    json.identifiers do
      json.array! 1.times do
        json.category 'ror'
        json.value ror_id.identifier
      end
    end
  end

end
