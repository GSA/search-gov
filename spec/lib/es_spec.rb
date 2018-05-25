require 'spec_helper'

describe ES do
  context "when working in ES submodules" do
    let(:elk_objs) { Array.new(3, ES::ELK.client_reader) }
    let(:ci_objs) { Array.new(3, ES::ELK.client_reader) }
    
    describe ".client_reader" do
      it "should return a different object in different submodules" do
        expect(ES::ELK.client_reader).to_not eq(ES::CustomIndices.client_reader)
      end

      it "should return the same object given successive invocations" do
        2.times do |i|
          expect(elk_objs[i]).to eq(elk_objs[i+1])
          expect(ci_objs[i]).to eq(ci_objs[i+1])
        end
      end
    end

    describe ".client_writers" do
      it "should return a different object in different submodules" do
        expect(ES::ELK.client_writers).to_not eq(ES::CustomIndices.client_writers)
      end

      it "should return the same object given successive invocations" do
        2.times do |i|
          expect(elk_objs[i]).to eq(elk_objs[i+1])
          expect(ci_objs[i]).to eq(ci_objs[i+1])
        end
      end
    end
  end

  context "when working in ES::ELK submodule" do
    describe ".client_reader" do
      it 'should use the value from the secrets.yml elasticsearch[reader][analytics] entry' do
        expect(ES::ELK.client_reader.transport.hosts.first[:host]).to eq(Rails.application.secrets.elasticsearch['reader']['analytics'])
      end
    end

    describe ".client_writers" do
      it 'should use the value(s) from the secrets.yml elasticsearch[writers][analytics] entry' do
        count = Rails.application.secrets.elasticsearch['writers']['analytics'].count
        expect(ES::ELK.client_writers.size).to eq(count)
        count.times do |i|
          expect(ES::ELK.client_writers.first.transport.hosts[i][:host]).to eq(Rails.application.secrets.elasticsearch['writers']['analytics'][i])
        end
      end
    end
  end

  context "when working in ES::CustomIndices submodule" do
    describe ".client_reader" do
      it 'should use the value from the secrets.yml elasticsearch[reader][custom_search] entry' do
        expect(ES::CustomIndices.client_reader.transport.hosts.first[:host]).to eq(Rails.application.secrets.elasticsearch['reader']['custom_search'])
      end
    end

    describe ".client_writers" do
      it 'should use the value(s) from the secrets.yml elasticsearch[writers][custom_search] entry' do
        count = Rails.application.secrets.elasticsearch['writers']['custom_search'].count
        expect(ES::CustomIndices.client_writers.size).to eq(count)
        count.times do |i|
          expect(ES::CustomIndices.client_writers.first.transport.hosts[i][:host]).to eq(Rails.application.secrets.elasticsearch['writers']['custom_search'][i])
        end
      end
    end
  end
end
