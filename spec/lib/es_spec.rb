require 'spec_helper'

describe ES do
  before do
    ES.class_variable_set :@@client_reader, nil
    ES.class_variable_set :@@client_writers, nil
    ES.class_variable_set :@@yaml, nil
  end

  after do
    ES.class_variable_set :@@client_reader, nil
    ES.class_variable_set :@@client_writers, nil
    ES.class_variable_set :@@yaml, nil
  end

  describe ".client_reader" do
    before do
      yaml = YAML.load_file("#{Rails.root}/spec/fixtures/yaml/elasticsearch_one_writer.yml")
      YAML.stub(:load_file).and_return yaml
    end

    it 'should use the value from the YAML file' do
      ES.client_reader.transport.hosts.first[:host].should == 'foo'
    end
  end

  describe ".client_writers" do
    context 'when there is one cluster' do
      before do
        yaml = YAML.load_file("#{Rails.root}/spec/fixtures/yaml/elasticsearch_one_writer.yml")
        YAML.stub(:load_file).and_return yaml
      end

      it 'should use the value from the YAML file' do
        ES.client_writers.size.should == 1
        ES.client_writers.first.transport.hosts.first[:host].should == 'localhost'
      end
    end

    context 'when there are multiple clusters' do
      before do
        yaml = YAML.load_file("#{Rails.root}/spec/fixtures/yaml/elasticsearch_two_writers.yml")
        YAML.stub(:load_file).and_return yaml
      end

      it 'should use the values from the YAML file' do
        ES.client_writers.size.should == 2
        ES.client_writers.first.transport.hosts.first[:host].should == 'localhost'
        ES.client_writers.last.transport.hosts.first[:host].should == '127.0.0.1'
      end
    end
  end

end
