require 'spec_helper'

describe CseAnnotation do
  fixtures :cse_annotations

  it { should validate_presence_of :url }
  it { should validate_uniqueness_of :url }

end
