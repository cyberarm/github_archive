# Inspired by:
# http://datasyndrome.com/post/51657080886/downloading-and-processing-the-github-data

require "date"
@time_now = Date.today

@start_time = Time.now
7.times do |i|
  @time = (@time_now-i).to_time
  year = @time.year
  month = @time.strftime('%m')
  day = @time.strftime('%d')

  for hour in (0..23) do
    if !File.exist?("data/temp/#{year}-#{month}-#{day}-#{hour}.json") && ARGV[1] == "extract"
      begin
        @raw_data = open("http://data.githubarchive.org/#{year}-#{month}-#{day}-#{hour}.json.gz")
        @data = Zlib::GzipReader.new(@raw_data).read
        File.open("data/temp/#{year}-#{month}-#{day}-#{hour}.json", "w") do |file|
          file.write @data
        end
        puts "Downloaded: #{year}-#{month}-#{day}-#{hour}.json.gz"

      rescue Zlib::DataError,Zlib::GzipFile::Error,OpenURI::HTTPError => e
        p e
      end

    elsif !File.exist?("data/temp/#{year}-#{month}-#{day}-#{hour}.json.gz") && ARGV[1] != "extract"
      begin
        @raw_data = open("http://data.githubarchive.org/#{year}-#{month}-#{day}-#{hour}.json.gz").read
        File.open("data/temp/#{year}-#{month}-#{day}-#{hour}.json.gz", "wb") do |file|
          file.write @raw_data
        end
        puts "Downloaded: #{year}-#{month}-#{day}-#{hour}.json.gz"

      rescue OpenURI::HTTPError => e
        p e
      end
    else
      puts "Skipped file...\n"
    end
  end
end

@end_time = Time.now
puts "Time to complete: #{Time.now-@start_time}"
