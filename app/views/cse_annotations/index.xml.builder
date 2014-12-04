xml.instruct! :xml, :version => "1.0"
xml.Annotations :start => 0, :num => @cse_annotations.size, :total => @cse_annotations.size do
  @cse_annotations.each do |cse_annotation|
    xml.Annotation :about => cse_annotation.url do
      xml.Label :name => CseAnnotation::LABEL
    end
  end
end
