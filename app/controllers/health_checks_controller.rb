class HealthChecksController < ApplicationController
  def new
    check_database
    check_opensearch

    render(plain: 'OK')
  end

  def check_opensearch
    OpenSearchConfig.search_client.cluster.health
  end

  def check_database
    Language.first
  end
end
