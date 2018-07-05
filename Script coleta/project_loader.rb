class ProjectLoader

  def self.get_list
    file = File.new("listaprojetos.txt", "r")
    ret = []
    while (line = file.gets)
        ret << line.strip.gsub("https://github.com/", "")
    end
    file.close
    ret
  end

end
