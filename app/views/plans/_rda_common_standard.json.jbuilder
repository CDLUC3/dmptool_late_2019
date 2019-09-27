# frozen_string_literal: true

json.ignore_nil!

# A JSON representation of a Data Management Plan in the Common Standard format
json.dmp do
  json.title plan.title
  json.description plan.description

  json.dmp_ids do
    json.array! 1.times do
      json.category 'url'
      json.value plan_url(plan)
    end
  end

  json.contact do
    json.partial! 'users/rda_common_standard', user: plan.owner, rel: 'primary_contact'
  end

  json.dm_staff plan.authors.where.not(email: plan.owner.email) do |user|
    json.partial! 'users/rda_common_standard', user: user, rel: 'author'
  end

  fundref_scheme = IdentifierScheme.where(name: 'fundref').first
  if fundref_scheme.present?
    fundref_id = plan.template.org.org_identifiers.select { |id| id.identifier_scheme_id == fundref_scheme.id }.first
    if plan.template.org.present? && fundref_id.present? && fundref_id.identifier.present?
      json.project do
        json.title plan.title
        json.funding do
          json.array! 1.times do
            json.funder_id fundref_id.identifier
            json.funding_status 'planned'
          end
        end
      end
    end
  end

end
