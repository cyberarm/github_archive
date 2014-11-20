# github_archive
Graphs the last seven days most popular languages by commits.

## Install
Clone or Download this repo.

`gem install gruff` (see this [post](https://shoobm.wordpress.com/2013/01/03/installing-rmagick-gem-on-windows-7/) to install rmagick on Windows with CRuby)

`gem install multi_json`

## Usage
### Fetch github archive data
`[j]ruby github_archive.rb download`

`[j]ruby github_archive.rb download extract` (extract is optional)

pre-extracts the archives, speeds up the parser by up to 3 minutes on JRuby.
### Generate graph
`[j]ruby github_archive.rb 8` number of threads.

`[j]ruby github_archive.rb 8 extracted` use if you used `extract` for downloading.
## Ruby Implementations Suggested Thread Count
### Tested on a quad-core Intel Core i7 2.0Ghz CPU with hyper-threading.
CRuby above 24 threads. 24 threads took `00:27:03` or 27 minutes.

Jruby 8 threads. 8 threads took `00:07:21` or 7 minutes.

Ensure you have good cooling, as JRuby can max out your CPU.
