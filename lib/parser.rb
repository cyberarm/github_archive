class GithubArchive
  class Parser
    attr_reader :files, :languages, :hash, :start_time, :finished
    def initialize(threads = ARGV.first.to_i || 4)
      puts "Loading data..."
      @threads = threads
      @pool    = []
      @start_time = Time.now
      @finished = false
      @files = Dir["./data/temp/*.json.gz"].reverse
      @languages = Set.new
      @hash = Hash.new(0)
    end

    def start_work
      @ranges = []
      n = @files.count / @threads
      @threads.times do |i|
        i += 1
        x,y = @ranges.last[1], (n*i) if defined?(@ranges.last[1]) && @ranges.last[1].is_a?(Integer)
        x,y = 0, (n*i) unless defined?(@ranges.last[1]) && @ranges.last[1].is_a?(Integer)
        range = [x,y]
        @ranges << range
      end

      @threads.times do |i|
        Thread.new do
          @pool << Thread.current
          process_data(@ranges[i-1][0]..@ranges[i-1][1])
        end
      end

      @pool.each do |thread|
        thread.join
      end
      @finished = true
      puts "Processed #{@files.count} files, in #{Time.at((Time.now-@start_time)).gmtime.strftime('%R:%S')}."
    end

    def process_data(range = 0..@files.count)
      start_time = Time.now
      @files[range].each do |file|
        puts "Processing file: #{file}..."
        @raw_data = File.open(file, "rb")
        begin
          puts "Decompressing file..."
          @data = Zlib::GzipReader.new(@raw_data).read
        rescue Zlib::DataError,Zlib::GzipFile::Error
          next
        end

        puts "Parsing JSON..."
        @data.each_line do |data|
          begin
            inner_data = JSON.load(data.chomp)
          rescue #JSON::ParseError
            next
          end
          if inner_data["type"] =~ /PushEvent/
            begin
              @languages << inner_data["repository"]["language"]
              language = inner_data["repository"]["language"]
              if @hash["#{language}"].to_s.length >= 1
                @hash["#{language}"] = @hash["#{inner_data["repository"]["language"]}"]+1
              else
                @hash["#{language}"] = 1
              end

            rescue NoMethodError
              next
            end
          end
        end
        puts "Finished processing #{file}.\n\n"
      end
      puts "Processed #{range.to_a.count} files, in #{Time.at((Time.now-start_time)).gmtime.strftime('%R:%S')}."
    end
  end
end