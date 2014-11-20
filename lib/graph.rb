class GithubArchive
  class Graph
    def initialize
      @graph = Gruff::Bar.new
      @labels = {}
      @counter = 0
      @list = {}
      @parser = GithubArchive::Parser.new
      @parser.start_work
      while @parser.finished == false;end
    end

    def process_data
      @parser.hash.each do |lang, value|
        next if lang.nil?
        lang = "Unknown" if lang.length <= 0
        @list[lang] = value
      end

      @list = @list.sort_by {|lang, value| value}

      @file = open("#{Dir.pwd}/data/languages-#{Time.now.strftime('%Y-%m-%d-%H-%M')}.txt", "w")
      @data = @list
      @sorted_data = []
      @data.each do |lang, value|
        @sorted_data << [value, lang]
      end

      @sorted_data.sort.reverse[0..9].each do |value, lang|
        @labels[Integer(@counter)] = lang
        array = []
        @counter.times {array << 0}
        array << value
        @graph.data lang.to_sym, array

        @counter+=1
      end

      @sorted_data.sort.reverse.each do |value, lang|
        @file.write "#{lang}: #{value}\n"
      end
    end

    def render
      @graph.title = 'Top 10 Github Languages by Commits'
      @graph.labels = @labels
      puts "Generating graph..."
      @graph.write("./graphs/graph-#{Time.now.strftime('%Y-%m-%d-%H-%M')}.png")
      puts "Finished."
    end
  end
end