require 'spec_helper'

describe Template do
  fixtures :templates, :affiliates

  # let(:template) { templates(:usagov_classic)}
  # subject { template }

  before { subject.stub(:valid_template_subclass?).and_return(true) }

  it { should belong_to :affiliate }
  it { should validate_presence_of(:type) }

  describe "#valid_template_subclass?" do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    # let(:template) { templates(:usagov_classic) }

    it "is a valide subclass if the type is part of the TEMPLATE_SUBCLASSES constant" do
      stub_const("Template::TEMPLATE_SUBCLASSES", ["Template::Classic", "Template::RoundedHeaderLink"])
      expect(affiliate.template.valid_template_subclass?).to be true
    end

    it "raises an error if it is not a valid subclass" do 
      affiliate.template.update_attribute(:type, "non-existant_type")
      expect{affiliate.template.valid_template_subclass?}.to raise_error("Not a valid subclass.")
    end
  end

  describe ".hidden" do 
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template_classic) { templates(:usagov_classic) }
    let(:template_rounded) { templates(:usagov_rounded_header_link) }

    it "returns an array of the non-active templates as virtual attributes" do
      affiliate.template
      expect(affiliate.templates.hidden.count).to eq 1
      expect(affiliate.templates.hidden[0]).to be_an_instance_of(template_rounded.class)
    end

  end

  describe "#load_schema" do 
    let(:affiliate) { affiliates(:usagov_affiliate) }

    it "loads the Deafult Schema if no schema is stored in DB" do 
      expect(Template::Classic.new.load_schema.to_json).to eq(Template::Classic::DEFAULT_SCHEMA.to_json)
    end

    it "loads the saved Schema if stored in DB" do 
      changed_to_schema = {"css" => "Test Schema"}.to_json
      affiliate.template.update_attribute(:schema, changed_to_schema)
      affiliate.template.reload
      expect(affiliate.template.load_schema.to_json).to eq(changed_to_schema)
    end
  end

  describe "#save_schema" do
    let(:affiliate) { affiliates(:usagov_affiliate) }

    it "Merges defaults and saves the schema" do 
      stub_const("Template::Classic::DEFAULT_SCHEMA", {"schema" => {"default" => "default" }})
      affiliate.template
      affiliate.template.save_schema({ "schema" => {"test_schema" => "test"}})
      expect(affiliate.template.load_schema).to eq(Hashie::Mash.new({"schema"=>{"default"=>"default", "test_schema"=>"test"}}))
    end

  end

  describe "#reset_schema" do 
    let(:affiliate) { affiliates(:usagov_affiliate) }

    it "resets the schema" do 
      affiliate.template
      affiliate.template.update_attribute(:schema, {"test" => "test"}.to_json)
      stub_const("Template::Classic::DEFAULT_SCHEMA", {"schema" => {"default" => "default" }})
      expect(affiliate.template.reset_schema).to eq(Hashie::Mash.new({"schema"=>{"default"=>"default"}}))
    end
  end
end
