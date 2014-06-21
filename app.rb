require "sinatra"
require "uri"
require "git"
require "fileutils"
require "dropbox_sdk"

require "dotenv"
Dotenv.load

tmp_loc = ENV["TMP_LOC"]
git_repo_url = ENV["GIT_REPO_URL"]
git_repo_name = ENV["GIT_REPO_NAME"]
git_user_name = ENV["GIT_USER_NAME"]
git_user_password = ENV["GIT_USER_PASSWORD"]
git_user_email = ENV["GIT_USER_EMAIL"]
dropbox_access_token = ENV["DROPBOX_ACCESS_TOKEN"]
dropbox_folder = ENV["DROPBOX_FOLDER"]

d = DropboxClient.new(dropbox_access_token)

git_url = URI.parse(git_repo_url)
git_url.user = git_user_name
git_url.password = git_user_password
git_repo_url_authed = git_url.to_s

def clone_repo(url, path, options = {})
  g = Git.clone(url, path)
  if options[:username]
    g.config("user.name", options[:username])
  end
  if options[:email]
    g.config("user.email", options[:email])
  end
  return g
end

def download_dropbox(d, dropbox_folder, path)
  # FUTURE: This should recursively descend into folders and download them,
  # however, for my purposes at the moment, I don't care.
  files = {}
  folder = d.metadata(dropbox_folder)
  folder["contents"].each do |file|
    if !file["is_dir"]
      file["local_path"] = file["path"].slice((dropbox_folder.length)..-1)
      repo_path = path + file["local_path"]
      contents, metadata = d.get_file_and_metadata(file["path"])
      open(repo_path, 'w') {|f| f.puts contents }
      files[file["local_path"]] = file
    end
  end

  return files
end

post "/hook/dropbox" do

  tmp_repo_path = tmp_loc + "repo-" + SecureRandom.uuid()
  FileUtils.rm_rf(tmp_repo_path)

  g = clone_repo(git_repo_url_authed, tmp_repo_path, username: git_user_name, email: git_user_email)
  files = download_dropbox(d, dropbox_folder, tmp_repo_path)

  g.add(:all=>true)

  changed_files = []
  g.status.changed.each do |file|
    changed_files.push(files["/" + file[0]])
  end

  message = "[committal] automatic dropbox update #{Time.now.to_s}\n\n"
  changed_files.each do |file|
    message += "- #{file["local_path"]} @ #{file["rev"]}\n" 
  end

  if changed_files != []
    begin
      g.commit(message)
      g.push
    rescue
      # File a github issue
    end
  end

  FileUtils.rm_rf(tmp_repo_path)

end

post "/hook/github" do

  tmp_repo_path = tmp_loc + "repo-" + SecureRandom.uuid()
  FileUtils.rm_rf(tmp_repo_path)

  g = clone_repo(git_repo_url, tmp_repo_path, username: git_user_name, email: git_user_email)
  files = download_dropbox(d, dropbox_folder, tmp_repo_path)

  g.add(:all=>true)

  changed_files = []
  g.status.changed.each do |file|
    changed_files.push(files["/" + file[0]])
  end

  g.reset_hard("HEAD")

  changed_files.each do |file|
    file["local_path"] = file["path"].slice((dropbox_folder.length)..-1)
    repo_path = tmp_repo_path + file["local_path"]
    file_handle = open(repo_path)
    response = d.put_file(file["path"], file_handle, true, file["rev"])
  end

  FileUtils.rm_rf(tmp_repo_path)

end