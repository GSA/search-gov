# frozen_string_literal: true

class BulkAffiliateStylesUploadResultsMailer < ApplicationMailer
  def results_email
    @results = params[:results]
    mail(to: params[:user].email, subject: "Bulk affiliate styles upload results for #{@results.name}")
  end
end
