require 'rubygems'
require 'logger'

require "git"
require 'ostruct'
require 'digest/md5'

class GitManipulator

  def initialize(repository, folder_name)
    @repository = repository
    @folder_name = folder_name

    @commit_ids = []

    result = `cd projects/#{@folder_name};git log`
  #  p result
    @commit_ids = result.split("\n\ncommit").reverse.select{|t| !t.nil? && !t.empty? && t != "\n"}.collect do |t|
      id = t.split("\n")[0].gsub("commit ", "").strip.chomp
      id
    end
    reset_head

  end

  def commits
    @repository.log
  end
  def commit_ids
    @commit_ids
  end

  def change_head(commit_id)
    @repository.checkout(commit_id)
    @last_id = @actual_id
    @actual_id = commit_id



  end
  def modified_files(extension: "*")
    @repository.diff(@last_id, @actual_id).stats[:files].keys.select{|k| k.end_with?(extension)}
  end
  def reset_head
    @last_id = @actual_id

    @repository.checkout(@commit_ids.last)
    @actual_id = @commit_ids.last

  end
  def vomito
    @repository
  end

  def get_commit_author(commit_id)
    result = `cd projects/#{@folder_name};git show #{commit_id} | head -n 8`
    result.split("Author:")[1].split("\n")[0].chomp.strip
  end
  def get_commit_date(commit_id)
    result = `cd projects/#{@folder_name};git show #{commit_id} --date=format:'%d-%m-%Y %H:%M:%S' | head -n 8`
    result.split("Date:")[1].split("\n")[0].chomp.strip
  end
  def get_smells(arquivos=nil)
    results = []
    files = arquivos || Dir["projects/#{@folder_name}/**/*.rb"]
    if arquivos
      files = arquivos.collect{|a| "projects/#{@folder_name}/#{a}"}
    end
    if !files.empty?
      output = `reek #{files.join(" ")}`
#      p "reek #{files.join(' ')}"
      if !output.nil? && !output.empty? && !output.include?("0 total warnings")

      output.split("projects/").select{|t| !t.nil? && !t.empty? && t != "\n"}.each do |o|
        result = OpenStruct.new
        result.filename = o.split("--")[0].chomp.strip

        o = o.split("--")[1]
        smells = o.split("\n")[1..-1].select{|t| !t.nil? && !t.empty? && t != "\n"}.collect{|s|
          smell = OpenStruct.new
          smell.id = Digest::MD5.hexdigest(s.chomp.strip)
          smell.type = s.split(":")[1]
          smell.message = s.chomp.strip
          smell
        }
        result.smells = smells
        results << result
      end
      end
    end
    results
  end
  def list_files(extension: "*")
    d = Dir["projects/#{@folder_name}/**/*.#{extension}"]
    d
  end
  def inverse_commits
    @repository.log.reverse
  end

  def self.clone(url, log: true)
    p "Fazendo download do repositorio" if log
    name = url.gsub("https://github.com/", "").gsub("/", "-").gsub(".git", "")
    g = Git.clone("https://github.com/#{url}", name, :path => 'projects')
    p "Download do repositório terminado!" if log

    GitManipulator.new(g, name)
  end
  def self.cloned?(name)
    File.directory?("projects/#{name}")
  end
  def self.delete_project(name)
    FileUtils.rm_rf("projects/#{name}") if GitManipulator.cloned?(name)

  end
  def self.load(name)
    g = Git.open("projects/#{name}")
    GitManipulator.new(g, name)
  end
end
