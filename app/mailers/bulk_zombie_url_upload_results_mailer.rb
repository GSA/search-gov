# frozen_string_literal: true

class BulkZombieUrlUploadResultsMailer < ApplicationMailer
  def results_email
    @results = params[:results]
    mail(to: params[:user].email, subject: "Bulk Zombie URL upload results for #{@results.file_name}")
  end
end
