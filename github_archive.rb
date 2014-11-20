require "set"
require "open-uri"
require "zlib"
require "time"

require 'multi_json'
require "gruff"

require_relative "lib/download" if ARGV[0] == "download"

require_relative "lib/parser"
require_relative "lib/graph"

begin
  Integer(ARGV[0]) # Number of threads
  @graph = GithubArchive::Graph.new
  @graph.process_data
  @graph.render
rescue ArgumentError => e
  exit
end
