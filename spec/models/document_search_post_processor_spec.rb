# frozen_string_literal: true

require 'spec_helper'

describe DocumentSearchPostProcessor do
  describe '#post_process_results' do
    subject(:processed_description) do
      described_class.new(true, [result]).tap(&:post_process_results).results.first.description
    end

    let(:result) { Hashie::Mash::Rash.new(title: 'Title', path: 'https://www.example.gov/page', description: description, content: content) }
    let(:highlighted_description) { "A \uE000matching\uE001 summary" }
    let(:plain_description) { 'A stored summary' }
    let(:highlighted_content) { "Page \uE000matching\uE001 text" }
    let(:plain_content) { 'Full page text' }

    context 'when description and content are highlighted' do
      let(:description) { highlighted_description }
      let(:content) { highlighted_content }

      it 'joins the highlighted description and content' do
        expect(processed_description).to eq("#{highlighted_description}...#{highlighted_content}")
      end
    end

    context 'when only the description is highlighted' do
      let(:description) { highlighted_description }
      let(:content) { plain_content }

      it 'uses the highlighted description' do
        expect(processed_description).to eq(highlighted_description)
      end
    end

    context 'when only the content is highlighted' do
      let(:description) { plain_description }
      let(:content) { highlighted_content }

      it 'uses the highlighted content' do
        expect(processed_description).to eq(highlighted_content)
      end
    end

    context 'when neither description nor content is highlighted' do
      let(:description) { plain_description }
      let(:content) { plain_content }

      it 'keeps the stored description' do
        expect(processed_description).to eq(plain_description)
      end
    end
  end
end
