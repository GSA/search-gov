# frozen_string_literal: true

class BulkUrlUploadResultsMailer < ApplicationMailer
  def results_email
    @results = params[:results]
    mail(to: params[:user].email, subject: "Bulk URL upload results for #{@results.name}")
  end
end
