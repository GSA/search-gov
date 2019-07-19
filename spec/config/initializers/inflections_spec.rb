# coding: utf-8
require 'spec_helper'

describe "Inflections" do
  context 'when locale = :es' do
    context 'if the spanish word is being pluralized' do
      it 'adds "es" if a noun ends in a consonant' do
        expect("flor".pluralize(2, :es)).to eq("flores")
      end

      it 'adds "s" if a noun ends in a vowel' do
        expect("libro".pluralize(2, :es)).to eq("libros")
      end

      it 'changes the "z" to "c" before adding "es" if a noun ends in a "z"' do
        expect("tapiz".pluralize(2, :es)).to eq("tapices")
      end
    end

    context 'if the spanish word is being singulularized' do
      it 'removes "es" spanish words if a noun ends in a consonant' do
        expect("flores".singularize( :es)).to eq("flor")
      end

      it 'removes "s" if a noun ends in a vowel' do
        expect("libros".singularize(:es)).to eq("libro")
      end

      it 'changes the "c" to "z" before removing "es" if a noun ends in a "z"' do
        expect("tapices".singularize(:es)).to eq("tapiz")
      end
    end
  end
end