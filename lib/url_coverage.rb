module UrlCoverage
  def self.overlap?(existing_url, new_url)
    existing_domain_str, existing_path_str = extract_domain_path(existing_url)
    new_domain_str, new_path_str = extract_domain_path(new_url)

    new_domain_str.end_with?(existing_domain_str) and paths_overlap?(existing_path_str, new_path_str)
  end

  def self.extract_domain_path(url)
    domain_str, path_str = url.split '/', 2
    domain_str.insert(0, '.') unless domain_str.start_with?('.')
    (path_str ||= '').insert 0, '/'
    return domain_str.downcase, path_str.downcase
  end

  def self.paths_overlap?(existing_path_str, new_path_str)
    existing_path_arr = existing_path_str.split('/')
    new_path_arr = new_path_str.split('/')
    return false if new_path_arr.size < existing_path_arr.size
    new_path_arr.first(existing_path_arr.size) == existing_path_arr
  end
end
