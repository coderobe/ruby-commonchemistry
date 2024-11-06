# CommonChemistry Ruby Library

A Ruby client library for the [Common Chemistry API](https://commonchemistry.cas.org/api), providing easy access to chemical substance data including search functionality, detailed substance information, and data export capabilities.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Getting Started](#getting-started)
  - [Initialization](#initialization)
  - [Search Substances](#search-substances)
  - [Get Substance Details](#get-substance-details)
  - [Export Substance Data](#export-substance-data)
- [Classes and Data Models](#classes-and-data-models)
- [Error Handling](#error-handling)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Search Substances**: Find substances by name, CAS Registry Number, or other identifiers.
- **Detailed Information**: Retrieve comprehensive data about a substance, including molecular properties and synonyms.
- **Data Export**: Export substance data in plain text format.
- **Error Handling**: Custom exceptions for graceful error management.
- **Easy Integration**: Designed to be simple and idiomatic for Ruby developers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'commonchemistry'
```

Or install it yourself with:

```shell
gem install commonchemistry
```

**Note**: Depends on httparty:

```shell
gem install httparty
```

## Getting Started

### Initialization

Begin by requiring the library and initializing a new client:

```ruby
require 'commonchemistry'

client = CommonChemistry::Client.new
```

### Search Substances

Search for substances using the `search` method:

```ruby
search_results = client.search(q: 'water', offset: 0, size: 10)

puts "Total Results: #{search_results.count}"
search_results.results.each do |result|
  puts "Name: #{result.name}, RN: #{result.rn}"
  # Optionally save the SVG image
  # result.save_image("#{result.rn}.svg")
end
```

**Parameters**:

- `q` (String): The search query.
- `offset` (Integer, optional): The offset for pagination.
- `size` (Integer, optional): The number of results to return.

### Get Substance Details

Retrieve detailed information about a substance:

```ruby
detail = client.detail(cas_rn: '7732-18-5')

puts "Name: #{detail.name}"
puts "Molecular Formula: #{detail.molecular_formula}"
puts "Molecular Mass: #{detail.molecular_mass}"

# Experimental Properties
detail.experimental_properties.each do |prop|
  puts "#{prop.name}: #{prop.property} (Source #{prop.source_number})"
end

# Synonyms
puts "Synonyms: #{detail.synonyms.join(', ')}"

# Save the SVG image
# detail.save_image("#{detail.rn}.svg")
```

**Parameters**:

- `cas_rn` (String, optional): The CAS Registry Number of the substance.
- `uri` (String, optional): The URI of the substance.

### Export Substance Data

Export substance data in plain text format:

```ruby
export_data = client.export(uri: detail.uri)
puts export_data
```

**Parameters**:

- `uri` (String): The URI of the substance.
- `return_as_attachment` (Boolean, optional): Whether to return the data as an attachment.

## Classes and Data Models

### Client

The main class for interacting with the API.

- `search(q:, offset: nil, size: nil)`: Searches for substances.
- `detail(cas_rn: nil, uri: nil)`: Retrieves detailed substance information.
- `export(uri:, return_as_attachment: false)`: Exports substance data.

### SearchResponse

Represents the response from a search query.

- `count` (Integer): Total number of results.
- `results` (Array of `SearchResult`): List of search results.

### SearchResult

Represents an individual search result.

- `rn` (String): CAS Registry Number.
- `name` (String): Substance name.
- `image` (String): SVG image data.

### DetailResult

Contains detailed information about a substance.

- `uri` (String)
- `rn` (String)
- `name` (String)
- `image` (String)
- `inchi` (String)
- `inchi_key` (String)
- `smile` (String)
- `canonical_smile` (String)
- `molecular_formula` (String)
- `molecular_mass` (Float)
- `experimental_properties` (Array of `ExperimentalProperty`)
- `property_citations` (Array of `PropertyCitation`)
- `synonyms` (Array of `String`)
- `replaced_rns` (Array of `String`)

### ExperimentalProperty

Represents an experimental property of a substance.

- `name` (String)
- `property` (String)
- `source_number` (Integer)

### PropertyCitation

Represents a citation for a property.

- `doc_uri` (String)
- `source_number` (Integer)
- `source` (String)

## Error Handling

The library defines custom exceptions for better error management:

- `CommonChemistry::InvalidRequestError`: Raised for invalid requests (HTTP 400, 404).
- `CommonChemistry::ServerError`: Raised when the server returns an internal error (HTTP 500).
- `CommonChemistry::UnexpectedResponseError`: Raised for any other unexpected HTTP responses.

**Example**:

```ruby
begin
  detail = client.detail(cas_rn: 'invalid-cas-rn')
rescue CommonChemistry::InvalidRequestError => e
  puts "Request Error: #{e.message}"
rescue CommonChemistry::ServerError => e
  puts "Server Error: #{e.message}"
rescue CommonChemistry::Error => e
  puts "An error occurred: #{e.message}"
end
```

---

*Disclaimer: This library is not affiliated with or endorsed by its upstream. Use responsibly.*
