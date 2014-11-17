require 'yaml'
namespace :usasearch do
  namespace :synonyms do

    desc "Convert existing synonyms into YAML entries"
    task :export_to_yaml, [:locale] => [:environment] do |t, args|
      hash = Synonym.where(locale: args.locale).reduce({}) do |hash, s|
        tokens = tokens_from_analyzer(s.entry, args.locale)
        details = { notes: s.notes, status: s.status, analyzed: tokens }
        diff = token_count(s.entry) - token_count(tokens)
        details.merge!(redundate_tokens: diff) unless diff.zero?
        hash[s.entry] = details
        hash
      end
      puts hash.to_yaml
    end

    def tokens_from_analyzer(synset, locale)
      options = { text: synset, analyzer: "#{locale}_analyzer", index: 'aa_all_but_synonyns' }
      ES::client_reader.indices.analyze(options)['tokens'].collect { |t| t['token'] }.uniq.join(', ')
    end

    def token_count(listing)
      listing.split(',').size
    end

  end
end