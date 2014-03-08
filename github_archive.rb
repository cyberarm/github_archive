require "set"
require 'json'
require "open-uri"
require "zlib"
require "time"
require "gruff"

require_relative "lib/download" if ARGV[0] == "download"

require_relative "lib/parser"
require_relative "lib/graph"

if Integer(ARGV[0])
  @graph = GithubArchive::Graph.new
  @graph.process_data
  @graph.render
end