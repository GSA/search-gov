namespace :db do
  task :setup => 'search_elastic:create_index'
end

namespace :search_elastic do
  desc 'Create an index for search_elastic'
  task create_index: :environment do
    index = ENV.fetch('SEARCHELASTIC_INDEX')

    template_generator = SearchElastic::Template.new("*#{index}*")

    ES.client.indices.put_template(
      body: template_generator.body,
      create: true,
      include_type_name: false,
      name: :search_elastic,
      order: 0
    )

    repo = SearchElastic::CollectionRepository.new
    repo.create_index!(index:, include_type_name: true)
  end
end
