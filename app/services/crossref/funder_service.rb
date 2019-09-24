# frozen_string_literal: true

module Crossref

  class CrossrefFunderError < StandardError; end

  class FunderService
    # Module that facilitates communications with the Crossref Funder API:
    #    https://github.com/ror-community/ror-api/blob/master/api_documentation.md
    HEARTBEAT_URI = 'https://api.crossref.org/heartbeat'.freeze
    URI = 'http://api.crossref.org/funders'.freeze
    MAX_RESULTS = 20.0
    MAX_PAGES = 5

    app_name = Branding.fetch(:application, :name)
    helpdesk = Branding.fetch(:organisation, :helpdesk_email)
    HEADERS = {
      'User-Agent': "#{app_name} (mailto: #{helpdesk})",
      'Accept': 'application/json'
    }.freeze

    # Ping the ROR API to determine if it is online
    def self.ping
      HTTParty.get(HEARTBEAT_URI).code == 200
    end

    # Search the Fundref API for the given string.
    # The limit appears to be 40 results (even with paging :/)
    def self.find_by_name(query)
      resp = query_crossref(URI, { 'query': query }, HEADERS)
      results = process_pages(resp, query) if resp.parsed_response.present? &&
        resp.parsed_response['message'].present? &&
        resp.parsed_response['message']['items'].present?
      results.present? ? results.flatten.uniq.sort_by { |a| a[:name] } : []
    rescue HTTParty::Error, SocketError => e
      raise Crossref::CrossrefFunderError, "Unable to connect to the Fundref API for `find_by_name`: #{e.message}"
    end

    class << self
      private

      def process_pages(resp, query)
        results = crossref_results_to_hash(resp)
        num_of_results = resp.parsed_response['total-results'].to_i
        # return [] unless num_of_results.to_i.is_a?(Integer)
        # Detemine if there are multiple pages of results
        pages = (num_of_results / MAX_RESULTS).to_f.ceil
        return results unless pages > 1
        # Gather the results from the additional page (only up to the max)
        (2..(pages > MAX_PAGES ? MAX_PAGES : pages)).each do |page|
          paged_resp = query_ror(URI, { 'query': query, page: page }, HEADERS)
          results += ror_results_to_hash(paged_resp) if paged_resp.parsed_response.is_a?(Hash) &&
                                                        paged_resp.parsed_response['message']['items'].present?
        end
        results || []
      end

      def query_crossref(uri, query, headers)
        resp = HTTParty.get(uri, query: query, headers: headers)
        # If we received anything but a 200 then log an error and return an empty array
        raise CrossrefFunderError, "Unable to connect to Fundref #{URI}?#{query}: status: #{resp.code}" if resp.code != 200
        # Return an empty array if the response did not have any results
        return nil if resp.code != 200 || resp.blank?
        resp
      end

      def crossref_results_to_hash(response)
        results = []
        return results unless response.parsed_response['message']['items'].is_a?(Array)
        response.parsed_response['message']['items'].each do |item|
          next unless item['uri'].present? && item['name'].present?
          results << { id: item['uri'], name: item['name'] }
        end
        results
      end
    end
  end

end
