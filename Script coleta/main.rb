require "./git_manipulator"
require "./project_loader"
require "./csv_export"
require 'digest/md5'
require 'fileutils'


ProjectLoader.get_list.each do |url|
  project_name = url.gsub("/", "-").gsub(".git", "")
  p "Projeto #{project_name}"
  GitManipulator.delete_project(project_name)
  project = GitManipulator.clone(url)

  data = []
  count = project.commit_ids.size
  init = 0
  project.commit_ids[init..count].each_with_index do |id,i|
    p "Analisando #{i+init} commit de #{count}"
    project.change_head(id)
    if i > 0
      arquivos = project.modified_files(extension: ".rb")
      data = {project: project_name, commit_id: id, commit_index: i+init, commit_author: project.get_commit_author(id), commit_date:project.get_commit_date(id), files: project.get_smells(arquivos)}
      CSVExport.export_project(data)

    end
  end


end
