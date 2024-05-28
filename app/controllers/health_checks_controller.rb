class HealthChecksController < ApplicationController
  def new
    check_database
    check_elasticsearch

    render(plain: 'OK')
  end

  def check_elasticsearch
    Es::ELK.client_reader.cluster.health
  end

  def check_database
    Language.first
  end
end
