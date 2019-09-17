# frozen_string_literal: true

require 'httparty'

module Dmphub

  # Service that sends DMP data to the DMPHub system and receives a DOI
  class PublicationService

    DEFAULT_HEADERS = headers = {
      'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
      'Accept': 'application/json'
    }.freeze

    def initialize
      @errors = []
      retrieve_auth_token
    end

    def register(dmp:)
      return nil unless @token.present?

      url = "#{base_api_url}/data_management_plans"
      resp = HTTParty.post(url, body: dmp, headers: authenticated_headers)
      payload = JSON.parse(resp.body)
      doi = payload.dmp_ids.select { |id| id.category == 'doi' }.first
      @errors << "register #{resp.code} : #{payload['error']} - #{payload['error_description']}" unless resp.code == 201
      @errors << "DMP registered but no DOI was returned!" if resp.code == 201 && doi.blank?
      doi
    end

    def is_published?(doi:)
      return false unless doi.present?

      url = "#{base_api_url}/data_management_plans/#{doi}"
      resp = HTTParty.get(url, headers: authenticated_headers)
      payload = JSON.parse(resp.body)
      @errors << "#{payload['error']} - #{payload['error_description']}" unless resp.code == 200
      resp.code == 200 && payload['error'].empty? && payload['title'].present?
    end

    private

    def retrieve_auth_token
      payload = {
        grant_type: 'client_credentials',
        client_id: Branding.fetch(:dmphub, :client_id),
        client_secret: Branding.fetch(:dmphub, :client_secret)
      }
      url = "#{base_api_url}/oauth/token"
      resp = HTTParty.post(url, body: args, headers: DEFAULT_HEADERS)
      response = JSON.parse(resp.body)
      @token = response if resp.code == 200
      @errors << "#{payload['error']} - #{payload['error_description']}" unless resp.code == 200

    rescue StandardError => se
      @errors << se.message
      return nil
    end

    def base_api_url
      "#{Branding.fetch(:dmphub, :base_path)}/#{Branding.fetch(:dmphub, :version)}"
    end

    def authenticated_headers
      DEFAULT_HEADERS.merge({
        'Authorization': "#{@token['token_type']} #{@token['access_token']}"
      })
    end

  end

end
