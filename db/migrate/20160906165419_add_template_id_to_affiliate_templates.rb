class AddTemplateIdToAffiliateTemplates < ActiveRecord::Migration
  def up
    @file = File.open('/tmp/AddTemplateIdToAffiliateTemplates.txt', 'a+')
    @file.puts "Starting migration #{Time.now}"

    begin
      add_column :affiliate_templates, :template_id, :integer
      add_index :affiliate_templates, :template_id

      change_column :affiliate_templates, :template_class, :string, null: true

      add_index :affiliate_templates, [:affiliate_id,:template_id], unique: true

      with_error_handling { remove_hidden_templates }
      with_error_handling { set_template_id }
      with_error_handling { set_active_template }

      @file.puts "Migration complete"
    ensure
      @file.close
    end
  end

  def down
    remove_index :affiliate_templates, column: [:affiliate_id, :template_id]
    remove_column :affiliate_templates, :template_id
    change_column :affiliate_templates, :template_class, :string, null: true

    #remove the rows we created when making templates available
    AffiliateTemplate.where('template_class is null').delete_all
  end

  private

  def set_active_template
    @file.puts "setting active templates"
    Affiliate.where('active_template_id is not null').each do |affiliate|
      @file.puts "setting active template for affiliate #{affiliate.id}"
      template_class = AffiliateTemplate.find(affiliate.active_template_id).template_class[10..-1]
      affiliate.update_column(:template_id, Template.find_by_klass(template_class).id)
      make_active_template_available(affiliate)
    end
  end

  def set_template_id
    @file.puts "setting template_id in affiliate_templates table"
    AffiliateTemplate.where('template_class is not null').all.each do |affiliate_template|
      @file.puts "setting template_id for affiliate #{affiliate_template.id}"
      template_class = affiliate_template.template_class[10..-1]
      affiliate_template.update_column(:template_id, Template.find_by_klass(template_class).id)
    end
  end

  def make_active_template_available(affiliate)
    @file.puts "making active templates available"
    unless affiliate.affiliate_templates.find_by_template_id(affiliate.template_id)
      puts "creating at row for affiliate #{affiliate.id}, template #{affiliate.template_id}"
      affiliate.affiliate_templates.create(template_id: affiliate.template_id)
    end
  end

  def remove_hidden_templates
    # This is safer than it looks. In the original code, an affiliate_templates row with
    # 'available' set to `false` is the equivalent of the row not being there at all.
    # And just in case, we're logging the rows we delete,
    # which should be fewer than half a dozen rows.
    @file.puts "removing hidden templates"

    AffiliateTemplate.where(available: false).each do |affiliate_template|
      @file.puts "Deleting affiliate template #{affiliate_template.id}:"
      @file.puts affiliate_template.attributes
      affiliate_template.delete
    end
  end

  def with_error_handling(&scarystuff)
    begin
      yield
    rescue StandardError => error
      @file.puts("#{error.message}\n#{error.backtrace.join("\n")}")
    end
  end
end
