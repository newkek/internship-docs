# gems (libs)
require 'sinatra/base'
require 'rest_client'
require 'open-uri'
require 'json'

# debugging
require 'pry-nav'

WHICH_JOB = 'http://localhost:8080/job/datastax.dev-tools.demo/'

class JenkinsMatrixGetter; end

class Neo < JenkinsMatrixGetter
  # @param [String] jenkins_page e.g. "http://localhost:8080/path/to/that/page"
  def initialize(jenkins_page)
    @jenkins_page = jenkins_page
  end

  def enter_the_matrix
    parse_matrix(::RestClient.get(@jenkins_page).to_s)
  end

  def parse_matrix(jenkins_html_src)
    grid_message = ''
    html = jenkins_html_src
    idx = html.index('<table id="configuration-matrix">') ||
          html.index('>Configuration Matrix</td>')
    warn 'Error: No matrix found!' if idx.nil?
    html[0..(idx || 0)] = ''
    idx = html.index('</table>')
    warn 'Error: No end to matrix table!' if idx.nil?
    html[idx..-1] = ''
    i    = 0
    rows = 0
    area = 0
    while i < html.length
      if html[i] == 'a' && html[i + 1] == 'l' && html[i + 2] == 't'
        j = i + 5
        buffer = ''
        while html[j] != '"'
          buffer += html[j]
          j += 1
        end
        case buffer
          when 'Failed'
            grid_message += 'f'
            i += 12
            area += 1
          when 'Success'
            grid_message += 's'
            i += 12
            area += 1
          when 'In progress'
            grid_message += 'w'
            i += 12
            area += 1
          when 'Not built'
            grid_message += 'n'
            i += 12
            area += 1
          else
            warn 'unknown matrix element type' << buffer
            grid_message += '?'
            i += 12
            area += 1
        end
      elsif html[i] == '<' && html[i..(i + 4)] == '</tr>'
        rows += 1
      end
      i += 1
    end
    rows -= 1
    cols = area.to_f.round(2) / rows
    [cols, rows, grid_message]
  end

  # @return [Boolean] true iff the page is accessible
  def red_pill?
    ::RestClient.get(@jenkins_page).code == 200
  end

  # @return [Boolean] true iff the page is not accessible
  def blue_pill?
    !red_pill?
  end
end

$neo = Neo.new(WHICH_JOB)

class JenkinsLiveRender < Sinatra::Base
  set :port, 3003
  set :public_folder, Dir.pwd

  before do
    if request.request_method == 'OPTIONS'
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Access-Control-Allow-Methods"] = "POST"

      halt 200
    end
  end

  get '/' do
    #'<a href="matrix.json">Enter the Matrix</a>'
    send_file 'index.html'
  end

  get '/css/:name' do |name|
    send_file '/css/' + name
  end

  get '/js/:name' do |name|
    send_file '/js/' + name
  end

  get '/matrix.json' do
    content_type :json
    if $neo.red_pill?
      {
        'grid'   => $neo.enter_the_matrix,
        'online' => true
      }.to_json
    else
      {
        'grid'   => nil,
        'online' => false
      }.to_json
    end
  end

  run!
end

JenkinsLiveRender.new

