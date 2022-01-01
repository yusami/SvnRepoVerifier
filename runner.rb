#!/usr/bin/env ruby

require 'bundler'
Bundler.require
require 'json'
require "open3"
require 'fileutils'
require 'digest'

class SvnRepoVerifier
  def initialize
    @config_file = "config.json".freeze
  end

  def do_verify(repo)
    cmd = ["svnadmin", "-r", "#{repo[:rev]}:HEAD", "verify", repo[:path]]
    puts '-command: "'+cmd.join(" ")+'"'
    o, e, s = Open3.capture3({"LC_ALL"=>"en_US.UTF-8"}, cmd.join(' '))
    puts "-----status-----\n#{s}"
    puts "-----out-----\n#{o}"
    puts "-----error-----\n#{e}"
    if e.length > 0 then
      @failure += 1
    end
  end

  def get_latest_rev(path)
    cmd = ["svnlook", "youngest", path]
    puts '-command: "'+cmd.join(" ")+'"'
    rev = nil
    IO.popen({"LC_ALL"=>"en_US.UTF-8"}, cmd, :err=>[:child, :out]) {|io|
      rev = io.read
      puts "-Latest rev.: " + rev
    }
    rev.chomp!
  end

  def read_config
    puts "-Reading config..."
    # config_file = "config.json"
    unless File.exist?( @config_file ) then
      puts "Config file is not found so example file is generated."
      File.open(@config_file, 'w') do |file|
        hash = { :Repositories => [{:path => "/path/to/repositories/", :rev => 0}]}
        str = JSON.pretty_generate(hash)
        file.write(str)
      end
    end

    File.open(@config_file) do |file|
      @sites = JSON.load(file, nil, {:symbolize_names => true, :create_additions => false})
      p @sites
    end

    # Get the current digest to confirm changes later.
    @digest = Digest::MD5.hexdigest(@sites.to_s)
  end

  def update_config
    puts "-Updating config..."

    # See if any changes are added.
    new_digest = Digest::MD5.hexdigest(@sites.to_s)
    # puts @digest
    # puts new_digest
    if @digest == new_digest then
      puts "-Nothing to update as no changes are found."
      return
    end

    # Keep the current config for safety.
    FileUtils.copy(@config_file, @config_file+".bak")

    # Write the config.
    File.open(@config_file, 'w') do |file|
      str = JSON.pretty_generate(@sites)
      file.write(str)
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

    puts "-Verifying repositories..."
    @sites[:Repositories].each do |entry|
     do_verify(entry)
      rev = get_latest_rev(entry[:path])
      # puts rev
      if rev.match(/^\d+$/) then
        # Update the config if valid number is returned.
        puts "-Revision, config: %d, latest: %d" % [entry[:rev], rev]
        entry[:rev] = rev
      else
        puts "-Invalid rev.: %s" % [rev]
      end
    end

    update_config
    # Result
    show_result
    raise "svn error" if @failure > 0
  end
end

sc = SvnRepoVerifier.new
sc.do_all_queries

