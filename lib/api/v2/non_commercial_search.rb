# frozen_string_literal: true

module Api::V2::NonCommercialSearch
  include Api::V2::SearchAsJson
  include Api::V2::AsJsonAppendWebSpellingCorrection
end
