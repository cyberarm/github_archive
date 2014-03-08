# All most all of this file was originally created by:
# http://datasyndrome.com/post/51657080886/downloading-and-processing-the-github-data

def prepend(number)
  return number <= 9 ? ("0" + number.to_s) : number.to_s
end
@start_time = Time.now
for year in ['14'] do
  for month in (1..12) do
    month = prepend(month)
    for day in (1..31) do
      day = prepend(day)
      unless File.exist?("data/temp/20#{year}-#{month}-#{day}-23.json.gz")
        begin
          @raw_data = open("http://data.githubarchive.org/20#{year}-#{month}-#{day}-23.json.gz").read
          File.open("data/temp/20#{year}-#{month}-#{day}-23.json.gz", "wb") do |file|
            file.write @raw_data
          end
         rescue OpenURI::HTTPError =>e
          puts e
         end
      else
        puts "Skipped file...\n\n"
      end
    end
  end
end
@end_time = Time.now
puts "Time to complete: #{Time.now-@start_time}"