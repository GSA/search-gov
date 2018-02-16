seed_file = File.join(Rails.root, 'db/seeds', 'templates.yml')
templates = YAML::load_file(seed_file)
templates.each do |template|
  Template.find_or_create_by(name: template['name']) do |record|
    record.klass = template['klass']
    record.description = template['description']
    record.schema = JSON.parse(template['schema'])
  end
end
