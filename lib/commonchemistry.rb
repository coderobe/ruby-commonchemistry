require 'httparty'
require 'json'

module CommonChemistry
  # Base error class for CommonChemistry errors
  class Error < StandardError; end

  # Error raised when a request is invalid (400, 404)
  class InvalidRequestError < Error; end

  # Error raised when the server returns an internal error (500)
  class ServerError < Error; end

  # Error raised for unexpected responses
  class UnexpectedResponseError < Error; end

  # Client class to interact with the Common Chemistry API
  class Client
    include HTTParty
    base_uri 'https://commonchemistry.cas.org/api'

    def initialize
      # Any initialization if needed
    end

    # Searches for substances matching the query
    #
    # @param q [String] The search query
    # @param offset [Integer, nil] The offset for pagination
    # @param size [Integer, nil] The number of results to return
    # @return [SearchResponse] The search results
    # @raise [InvalidRequestError] if the request is invalid
    # @raise [ServerError] if the server returns an error
    # @raise [UnexpectedResponseError] for other errors
    def search(q:, offset: nil, size: nil)
      params = { q: q }
      params[:offset] = offset if offset
      params[:size] = size if size

      response = self.class.get('/search', query: params)
      handle_response(response) do
        SearchResponse.new(response.parsed_response)
      end
    end

    # Retrieves detailed information about a substance
    #
    # @param cas_rn [String, nil] The CAS registry number
    # @param uri [String, nil] The URI of the substance
    # @return [DetailResult] The detailed substance information
    # @raise [InvalidRequestError] if the request is invalid
    # @raise [ServerError] if the server returns an error
    # @raise [UnexpectedResponseError] for other errors
    def detail(cas_rn: nil, uri: nil)
      params = {}
      params[:cas_rn] = cas_rn if cas_rn
      params[:uri] = uri if uri

      response = self.class.get('/detail', query: params)
      handle_response(response) do
        DetailResult.new(response.parsed_response)
      end
    end

    # Exports substance data
    #
    # @param uri [String] The URI of the substance
    # @param return_as_attachment [Boolean] Whether to return as attachment
    # @return [String] The exported data
    # @raise [InvalidRequestError] if the request is invalid
    # @raise [ServerError] if the server returns an error
    # @raise [UnexpectedResponseError] for other errors
    def export(uri:, return_as_attachment: false)
      params = { uri: uri, returnAsAttachment: return_as_attachment }
      response = self.class.get('/export', query: params)
      handle_response(response) do
        response.body  # Since the response is text/plain
      end
    end

    private

    def handle_response(response)
      case response.code
      when 200
        yield
      when 400, 404
        raise InvalidRequestError, "Invalid Request (#{response.code})"
      when 500
        raise ServerError, "Internal Server Error (#{response.code})"
      else
        raise UnexpectedResponseError, "Unexpected response code: #{response.code}"
      end
    end
  end

  # Represents a search response from the API
  class SearchResponse
    attr_reader :count, :results

    def initialize(data)
      @count = data['count'].to_i
      @results = (data['results'] || []).map { |result| SearchResult.new(result) }
    end
  end

  # Represents an individual search result
  class SearchResult
    attr_reader :rn, :name, :image

    def initialize(data)
      @rn = data['rn']
      @name = data['name']
      @image = data['image']
    end

    # Saves the SVG image to a file
    #
    # @param filename [String] The filename to save the image as
    def save_image(filename)
      File.open(filename, 'w') { |file| file.write(@image) }
    end
  end

  # Represents detailed information about a substance
  class DetailResult
    attr_reader :uri, :rn, :name, :image, :inchi, :inchi_key, :smile,
                :canonical_smile, :molecular_formula, :molecular_mass,
                :experimental_properties, :property_citations,
                :synonyms, :replaced_rns

    def initialize(data)
      @uri = data['uri']
      @rn = data['rn']
      @name = data['name']
      @image = data['image']
      @inchi = data['inchi']
      @inchi_key = data['inchiKey']
      @smile = data['smile']
      @canonical_smile = data['canonicalSmile']
      @molecular_formula = data['molecularFormula']
      @molecular_mass = data['molecularMass']
      @experimental_properties = (data['experimentalProperties'] || []).map { |prop| ExperimentalProperty.new(prop) }
      @property_citations = (data['propertyCitations'] || []).map { |citation| PropertyCitation.new(citation) }
      @synonyms = data['synonyms'] || []
      @replaced_rns = data['replacedRns'] || []
    end

    # Saves the SVG image to a file
    #
    # @param filename [String] The filename to save the image as
    def save_image(filename)
      File.open(filename, 'w') { |file| file.write(@image) }
    end
  end

  # Represents an experimental property of a substance
  class ExperimentalProperty
    attr_reader :name, :property, :source_number

    def initialize(data)
      @name = data['name']
      @property = data['property']
      @source_number = data['sourceNumber']
    end
  end

  # Represents a property citation
  class PropertyCitation
    attr_reader :doc_uri, :source_number, :source

    def initialize(data)
      @doc_uri = data['docUri']
      @source_number = data['sourceNumber']
      @source = data['source']
    end
  end
end


## Usage Example

# def from_name n
#   client = CommonChemistry::Client.new
#   search_results = client.search(q: n)
#   client.detail(cas_rn: search_results.results.first.rn)
# end

# client = CommonChemistry::Client.new

# export_data = client.export(uri: 'substance/pt/7732185')
# puts export_data

# ibu = from_name 'ibuprofen'
# puts "Name: #{ibu.name}"
# puts "Molecular Formula: #{ibu.molecular_formula}"

# require 'pry'
# binding.pry
