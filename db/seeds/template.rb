seed_file = File.join(Rails.root, 'db/seeds', 'templates.yml')
templates = YAML::load_file(seed_file)
templates.each do |template|
  Template.find_or_create_by_name(template['name'],
                                  klass: template['klass'],
                                  description: template['description'],
                                  schema: JSON.parse(template['schema']))
end
