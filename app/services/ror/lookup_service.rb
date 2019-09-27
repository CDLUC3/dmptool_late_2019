# frozen_string_literal: true

module Ror

  class RorError < StandardError; end

  class LookupService
    # Module that facilitates communications with the ROR API:
    #    https://github.com/ror-community/ror-api/blob/master/api_documentation.md
    HEARTBEAT_URI = 'https://api.ror.org/heartbeat'.freeze
    URI = 'https://api.ror.org/organizations'.freeze
    ROR_MAX_RESULTS = 20.0
    MAX_PAGES = 5

    app_name = Branding.fetch(:application, :name)
    helpdesk = Branding.fetch(:organisation, :helpdesk_email)
    HEADERS = {
      'User-Agent': "#{app_name} (mailto: #{helpdesk})",
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }.freeze

    # Ping the ROR API to determine if it is online
    def self.ping
      HTTParty.get(HEARTBEAT_URI).code == 200
    end

    # Search the ROR API for the given string. This will search name, acronyms, aliases, etc.
    # @return an Array of Hashes { id: 'https://ror.org/12345', name: 'Sample University' }
    # The ROR limit appears to be 40 results (even with paging :/)
    def self.find_by_ror_name(query)
      resp = query_ror(URI, { 'query': query }, HEADERS)
      results = process_pages(resp, query) if resp.parsed_response.present? && resp.parsed_response['items'].present?
      results.present? ? results.flatten.uniq.sort_by { |a| a[:name] } : []
    rescue HTTParty::Error, SocketError => e
      raise RorError, "Unable to connect to the ROR API for `find_by_ror_name`: #{e.message}"
    end

    class << self
      private

      def process_pages(resp, query)
        results = ror_results_to_hash(resp)
        num_of_results = resp.parsed_response['number_of_results'].to_i
        # return [] unless num_of_results.to_i.is_a?(Integer)
        # Detemine if there are multiple pages of results
        pages = (num_of_results / ROR_MAX_RESULTS).to_f.ceil
        return results unless pages > 1
        # Gather the results from the additional page (only up to the max)
        (2..(pages > MAX_PAGES ? MAX_PAGES : pages)).each do |page|
          paged_resp = query_ror(URI, { 'query.names': query, page: page }, HEADERS)
          results += ror_results_to_hash(paged_resp) if paged_resp.parsed_response.is_a?(Hash) &&
                                                        paged_resp.parsed_response['items'].present?
        end
        results || []
      end

      def query_ror(uri, query, headers)
        resp = HTTParty.get(uri, query: query, headers: headers)
        # If we received anything but a 200 then log an error and return an empty array
        raise RorError, "Unable to connect to ROR #{URI}?#{query}: status: #{resp.code}" if resp.code != 200
        # Return an empty array if the response did not have any results
        return nil if resp.code != 200 || resp.blank?
        resp
      end

      def ror_results_to_hash(response)
        results = []
        return results unless response.parsed_response['items'].is_a?(Array)
        response.parsed_response['items'].each do |item|
          next unless item['id'].present? && item['name'].present?
          results << { id: item['id'], name: item['name'] }
        end
        results
      end
    end
  end

end
