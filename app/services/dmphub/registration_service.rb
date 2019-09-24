# frozen_string_literal: true

require 'httparty'

module Dmphub

  # Service that sends DMP data to the DMPHub system and receives a DOI
  class RegistrationService

    DEFAULT_HEADERS = headers = {
      'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
      'Accept': 'application/json'
    }.freeze

    def initialize
      @errors = []
      retrieve_auth_token

      @base_path = "#{Branding.fetch(:dmphub, :base_path)}"
      @auth_path = "#{@base_path}#{Branding.fetch(:dmphub, :token_path)}"
      @create_path = "#{@base_path}#{Branding.fetch(:dmphub, :create_path)}"
      @show_path = "#{@base_path}#{Branding.fetch(:dmphub, :show_path)}"
      @index_path = "#{@base_path}#{Branding.fetch(:dmphub, :index_path)}"

      Rails.logger.error @errors.join(', ') if @errors.any?
    end

    def register(dmp:)
      retrieve_auth_token unless @token.present?
      return nil unless dmp.present?

      resp = HTTParty.post(@create_path, body: JSON.parse(dmp), headers: authenticated_headers)
      payload = JSON.parse(resp.body)
      doi = payload.fetch('content', {}).fetch('dmp', {}).fetch('dmp_ids', []).select do |id|
        id['category'] == 'doi'
      end

      @errors << "register #{resp.code} : #{payload['error']} - #{payload['error_description']}" unless resp.code == 201
      @errors << "DMP registered but no DOI was returned!" if resp.code == 201 && doi.blank?

      Rails.logger.error @errors.join(', ') if @errors.any?
      doi.first&.fetch('value', '')
    end

    def is_published?(doi:)
      retrieve_auth_token unless @token.present?
      return false unless doi.present?

      resp = HTTParty.get(@show_path, headers: authenticated_headers)
      payload = JSON.parse(resp.body)
      @errors << "#{payload['error']} - #{payload['error_description']}" unless resp.code == 200

      Rails.logger.error @errors.join(', ') if @errors.any?

      resp.code == 200 && payload['error'].empty? && payload['title'].present?
    end

    private

    def retrieve_auth_token
      payload = {
        grant_type: 'client_credentials',
        client_id: Branding.fetch(:dmphub, :client_uid),
        client_secret: Branding.fetch(:dmphub, :client_secret)
      }
      resp = HTTParty.post(@auth_path, body: payload, headers: DEFAULT_HEADERS)
      response = JSON.parse(resp.body)
      @token = response if resp.code == 200
      @errors << "#{payload['error']} - #{payload['error_description']}" unless resp.code == 200
    rescue StandardError => se
      @errors << se.message
      return nil
    end

    def authenticated_headers
      agent = "#{Branding.fetch(:dmphub, :user_agent)} (#{Branding.fetch(:dmphub, :client_uid)})"
      DEFAULT_HEADERS.merge({
        'User-Agent': agent,
        'Authorization': "#{@token['token_type']} #{@token['access_token']}"
      })
    end

  end

end

# Sample response from the DMPHub:
#
# {
#   "generation_date"=>"2019-09-24 14:21:14 -0700",
#   "caller"=>"vanilla_roadmap",
#   "source"=>"POST http://localhost:3003/api/v1/data_management_plans",
#   "content"=>{
#     "dmp"=>{
#       "created"=>"2019-09-24 21:21:14 UTC",
#       "modified"=>"2019-09-24 21:21:14 UTC",
#       "links"=>[{
#         "rel"=>"self",
#         "href"=>"http://localhost:3000/api/v1/data_management_plans/10.80030/panv-q907"
#       }],
#       "title"=>"BCO DMO Template Test",
#       "description"=>"One thing to remember when doing this, is that your JSON content's size ...",
#       "language"=>"en",
#       "ethical_issues_exist"=>"unknown",
#       "dmp_ids"=>[
#         {
#           "created"=>"2019-09-24 21:21:14 UTC",
#           "modified"=>"2019-09-24 21:21:14 UTC",
#           "category"=>"url",
#           "provenance"=>"vanilla_roadmap",
#           "value"=>"http://localhost:3000/plans/32697"
#         }, {
#           "created"=>"2019-09-24 21:21:14 UTC",
#           "modified"=>"2019-09-24 21:21:14 UTC",
#           "category"=>"doi",
#           "provenance"=>"datacite",
#           "value"=>"10.80030/panv-q907"
#         }
#       ],
#       "contact"=>{
#         "created"=>"2019-09-24 21:21:14 UTC",
#         "modified"=>"2019-09-24 21:21:14 UTC",
#         "name"=>"Brian Riley",
#         "mbox"=>"brian.riley@ucop.edu",
#         "organizations"=>[{
#           "created"=>"2019-09-24 21:21:14 UTC",
#           "modified"=>"2019-09-24 21:21:14 UTC",
#           "name"=>"University of California, Office of the President (UCOP)",
#           "identifiers"=>[{
#             "created"=>"2019-09-24 21:21:14 UTC",
#             "modified"=>"2019-09-24 21:21:14 UTC",
#             "category"=>"ror",
#             "provenance"=>"vanilla_roadmap",
#             "value"=>"https://ror.org/04032fz76"
#           }]
#         }],
#         "contact_ids"=>[{
#           "created"=>"2019-09-24 21:21:14 UTC",
#           "modified"=>"2019-09-24 21:21:14 UTC",
#           "category"=>"orcid",
#           "provenance"=>"vanilla_roadmap",
#           "value"=>"0000-0001-9870-5882"
#         }]
#       },
#       "project"=>{
#         "created"=>"2019-09-24 21:21:14 UTC",
#         "modified"=>"2019-09-24 21:21:14 UTC",
#         "title"=>"BCO DMO Template Test",
#         "description"=>"One thing to remember when doing this, is that your JSON content's size ...",
#         "start_on"=>"2019-09-24 21:21:14 UTC",
#         "end_on"=>"2021-09-24 21:21:14 UTC"
#       },
#       "datasets"=>[{
#         "created"=>"2019-09-24 21:21:14 UTC",
#         "modified"=>"2019-09-24 21:21:14 UTC",
#         "title"=>"BCO DMO Template Test",
#         "type"=>"dataset",
#         "personal_data"=>"unknown",
#         "sensitive_data"=>"unknown"
#       }]
#     }
#   }
# }
