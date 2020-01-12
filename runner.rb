#!/usr/bin/env ruby

require 'bundler'
Bundler.require
require 'json'
require "open3"

class SvnRepoVerifier
  def do_verify(path)
    # cmd = ["svnadmin","-q", "verify",path]
    # puts cmd.to_s
    # IO.popen({"LC_ALL"=>"en_US.UTF-8"}, cmd, :err=>[:child, :out]) {|io|
    #   puts io.read
    # }

    cmd = ["svnadmin", "verify",path]
    o, e, s = Open3.capture3({"LC_ALL"=>"en_US.UTF-8"}, cmd.join(' '))
    puts "-----out-----\n#{o}"
    puts "-----error-----\n#{e}"
    if e.length > 0 then
      @failure += 1
    end
    puts "-----status-----\n#{s}"
  end

  def read_config
    puts "Reading config..."
    config_file = "config.json"
    unless File.exist?( config_file ) then
      puts "Config file is not found so example file is generated."
      File.open(config_file, 'w') do |file|
        hash = { "Repositories" => [ "/path/to/repositories/"]}
        str = JSON.pretty_generate(hash)
        file.write(str)
      end
    end

    File.open(config_file) do |file|
      @sites = JSON.load(file, nil, {:symbolize_names => true, :create_additions => false})
      # p @sites
      p @sites[:Repositories]
    end
  end

  def show_result
    puts "-Total: %d, Success: %d, Failure: %d" % [@total, @total-@failure, @failure]
  end

  def do_all_queries
    # Set up config
    read_config
    # Counters for result
    @total =  @sites[:Repositories].count
    @failure = 0

    puts "Checking repositories..."
    @sites[:Repositories].each do |path|
      do_verify(path)
    end

    # Result
    show_result
  end
end

sc = SvnRepoVerifier.new
sc.do_all_queries

