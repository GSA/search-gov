require 'keen'

config = (YAML.load_file("#{Rails.root}/config/keen.yml") || {})[Rails.env]

if config.try(:keys).try(:any?)
  %w(project_id master_key write_key read_key).each do |field|
    Keen.send(:"#{field}=", config[field]) if config[field]
  end
else
  STDERR.puts "No Keen configuration provided!"
end
