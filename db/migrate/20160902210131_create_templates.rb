class CreateTemplates < ActiveRecord::Migration
  def up
    create_table :templates do |t|
      t.string :name, :limit => 50, null: false
      t.string :klass, :limit => 50, null: false
      t.string :description, null: false
      t.text :schema, null: false

      t.timestamps
    end
    add_index :templates, :name, :unique => true

    create_templates
  end

  def create_templates
    seed_file = File.join(Rails.root, 'db/seeds', 'templates.yml')
    templates = YAML::load_file(seed_file)
    templates.each do |template|
      Template.find_or_create_by_name(template['name'],
                                      klass: template['klass'],
                                      description: template['description'],
                                      schema: JSON.parse(template['schema']))
    end
  end

  def down
    drop_table :templates
  end
end
