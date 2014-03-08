require "set"
require 'json'
require "open-uri"
require "zlib"
require "time"
require "gruff"
require_relative "lib/parser"
#require_relative "lib/download"
require_relative "lib/graph"

@graph = GithubArchive::Graph.new
@graph.process_data
@graph.render