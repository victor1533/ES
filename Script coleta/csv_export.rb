require 'net/http'
require 'json'
 require "csv"

class CSVExport
  def self.exists?(filename)
    File.exist?("#{filename}")
  end
  def self.rows(filename)
    CSV.read(filename).count-1
  end
  def self.export_project(gigante)
  #  p gigante[:smells]
  if(CSVExport.exists?("#{gigante[:project]}.csv"))
    op = "ab"
  else
    op = "wb"
  end
    CSV.open("#{gigante[:project]}.csv", op) do |csv|
      csv << ["commit_id", "commit_author", "commit_index", "date", "filename", "smell_id","smell_type", "smell_description"] if op == "wb"#cabecalho

      gigante[:files].each do |file|
        file.smells.each do |smell|
          csv << [gigante[:commit_id], gigante[:commit_author],gigante[:commit_index], gigante[:commit_date], file.filename, smell.id,smell.type ,smell.message]
        end
      end
    end
  end
end
