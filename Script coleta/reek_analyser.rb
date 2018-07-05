class ReekAnalyser
  require 'rubygems'
  require 'logger'

  require "git"
  require 'ostruct'





  def analyse_path(path="", extension: "*")
    d = Dir["#{path}**/*.#{extension}"]
    results = []
    d.each do |file|
      output = `reek #{d.first}`
      result = OpenStruct.new
      result.filename = output.split("--")[0].chomp.strip
      output = output.split("--")[1]
      smells = output.split("\n")[1..-1].collect{|s| s.chomp.strip}

      result.smells = smells
      results << result
    end

    results
  end

  def analyse_file

  end
end
