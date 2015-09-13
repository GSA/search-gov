git_refs = git_sha = 'unknown'

git_info = `git log -1 --format="%h %d"`.chomp
if git_info.length > 0
  git_sha, refs = git_info.split(/\s+/, 2)
  git_refs = refs.gsub(/[\(\)]/, '').split(/[, ]+/).
    map { |r| r.sub('origin/', '') }.
    reject { |r| r == 'HEAD' || r == 'deploy' }.
    sort.uniq.join(', ')
end

system_name = ::File.read(::File.join(Rails.root, 'config', 'system_name.txt')) rescue nil
show_header = system_name.present?

UsasearchGitInfo = Struct.new(:sha, :refs, :system_name, :show_header)
$git_info = UsasearchGitInfo.new(git_sha, git_refs, system_name, show_header)
