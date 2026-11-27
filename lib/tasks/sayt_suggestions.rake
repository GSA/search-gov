# frozen_string_literal: true

namespace :usasearch do
  namespace :sayt_suggestions do
    desc 'expire SAYT suggestions that have not been updated in X days (defaults to 30)'
    task :expire, [:days_back] => [:environment] do |_t, args|
      args.with_defaults(days_back: 30)
      SaytSuggestion.expire(args.days_back.to_i)
    end
  end
end
