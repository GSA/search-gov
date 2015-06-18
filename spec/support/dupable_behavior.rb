shared_examples 'dupable' do |do_not_dup_attributes|
  subject(:dup_instance) { original_instance.dup }

  do_not_dup_attributes.each do |do_not_dup_attribute|
    its(do_not_dup_attribute) { should be_nil }
  end
end

shared_examples 'site dupable' do
  include_examples 'dupable', %w(affiliate_id)
end
