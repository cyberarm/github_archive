class GithubArchive
  class Parser
    attr_reader :files, :languages, :hash, :start_time, :finished
    def initialize(threads = ARGV.first.to_i || 4)
      puts "Loading data..."
      @threads = threads
      @pool    = []
      @start_time = Time.now
      @finished = false
      @files = Dir["./data/temp/*.json"].reverse if ARGV[1] == 'extracted'
      @files = Dir["./data/temp/*.json.gz"].reverse if ARGV[1] != 'extracted'
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

      # @pool.each do |thread|
      #   thread.join
      # end

      # Block the world!
      i_i = 0
      loop do
        count = 0
        @pool.each do |thread|
          if thread.alive?
            count+=1
          end
        end
        i_i+=1
        break if (count == 0 && i_i >= 1_000_000)
      end
      puts i_i

      @finished = true
      puts "Processed #{@files.count} files, in #{Time.at((Time.now-@start_time)).gmtime.strftime('%R:%S')}."
    end

    def process_data(range = 0..@files.count)
      start_time = Time.now
      @files[range].each do |file|
        puts "Processing file: #{file}..."
        if ARGV[1] != 'extracted'
          @data = File.open(file, "rb")
          begin
            puts "Decompressing file..."
            @data = Zlib::GzipReader.new(@raw_data).read
          rescue Zlib::DataError,Zlib::GzipFile::Error
            next
          end

        else
          @data = File.open(file, "r")
        end

        puts "Parsing JSON..."
        @data.each_line do |data|
          begin
            inner_data = MultiJson.load(data.chomp)
          rescue MultiJson::ParseError => e
            p e
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
