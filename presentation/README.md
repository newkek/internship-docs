# Intern Presentation 2015 (Drivers and Dev Tools)

## DataStax presentation
Run the presentation locally by using `./present.sh`

For the actual event, launch with ngrok using `./present.sh --live` or `./present.sh --when-execs-are-here`, which are equivalent.

To allow for Jenkins matrix live-rendering, use `ruby jenkins-render.rb` to run the presentation instead. This will use Ruby Sinatra instead of Grunt to serve the presentation slides. Slide sync should still work.

## Caveats
To control the page, use `[url]/server.html` instead of `[url]/index.html`. Only give audience members the `[url]/index.html`.

## Installation and Usage on Mac OS (for Ruby server)
```bash
cd ROOT_DIR_OF_SLIDESHOW
brew install ruby      # install ruby
gem install bundler    # like installing npm
bundle install         # like running `npm install'
# Go to Jenkins website and download jenkins.war
# (http://mirrors.jenkins-ci.org/war/latest/jenkins.war)
java -jar jenkins.war
# Go to localhost:8080 (jenkins), and create
# a multi-configuration job "datastax.dev-tools.demo" with
# some matrix elements
# Switch to a different console window
ruby ruby-server.rb
# look at localhost:3003/matrix.json
# look at localhost:3003
ngrok -proto="http" 3003
# perform slideshow
```
