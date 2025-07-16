# frozen_string_literal: true

module ES
  ES_CONFIG = Rails.application.config_for(:elasticsearch_client).freeze

  def self.client
    @client ||= Elasticsearch::Client.new(
      ES_CONFIG.merge(
        randomize_hosts: true,
        retry_on_failure: true,
        reload_connections: false,
        reload_on_failure: false,
        transport_options: {
          ssl: { verify: false }
        },
        logger: Rails.logger
      )
    )
  end

  def self.create_index
    index_name = ENV.fetch('SEARCHELASTIC_INDEX')
    min_age = ENV.fetch('SEARCHELASTIC_INDEX_RETENTION_MIN_AGE')
    policy_name = 'index_policy'
  
    # 1. Create or update ILM policy
    client.ilm.put_policy(
      policy_id: policy_name,
      body: {
        policy: {
          phases: {
            hot: {
              min_age: '0ms',
              actions: {
                set_priority: { priority: 100 }
              }
            },
            delete: {
              min_age: min_age,
              actions: { delete: {} }
            }
          }
        }
      }
    )
    Rails.logger.info("ILM policy '#{policy_name}' created or updated.")
  
    # 2. Apply index template (can update if already exists)
    template_generator = SearchElastic::Template.new("*#{index_name}*")
    client.indices.put_template(
      name: index_name,
      body: template_generator.body,
      create: false,
      include_type_name: false,
      order: 0
    )
    Rails.logger.info("Index template for '#{index_name}' applied.")
  
    if client.indices.exists?(index: index_name)
      Rails.logger.info("Index '#{index_name}' already exists. Ensuring ILM policy is attached and delete.min_age is updated.")
  
      # Get current index settings
      current_settings = client.indices.get_settings(index: index_name)
  
      # Check if delete.min_age needs to be updated
      lifecycle = current_settings.dig(index_name, 'settings', 'index', 'lifecycle', 'name')
      if lifecycle != policy_name
        client.indices.put_settings(
          index: index_name,
          body: {
            index: {
              lifecycle: {
                name: policy_name
              }
            }
          }
        )
      end
  
      # Check if delete.min_age needs to be updated
      current_min_age = current_settings.dig(index_name, 'settings', 'index', 'lifecycle', 'policy', 'phases', 'delete', 'min_age')
      if current_min_age != min_age
        client.indices.put_settings(
          index: index_name,
          body: {
            index: {
              lifecycle: {
                policy: {
                  phases: {
                    delete: {
                      min_age: min_age
                    }
                  }
                }
              }
            }
          }
        )
      end
    else
      # Create index if it doesn't exist
      client.indices.create(
        index: index_name,
        body: {
          settings: {
            index: {
              lifecycle: {
                name: policy_name
              }
            }
          }
        }
      )
    end
  end
    index_name = ENV.fetch('SEARCHELASTIC_INDEX')
    min_age = ENV.fetch('SEARCHELASTIC_INDEX_RETENTION_MIN_AGE')
    policy_name = 'index_policy'

    # 1. Create or update ILM policy
    client.ilm.put_policy(
      policy_id: policy_name,
      body: {
        policy: {
          phases: {
            hot: {
              min_age: '0ms',
              actions: {
                set_priority: { priority: 100 }
              }
            },
            delete: {
              min_age: min_age,
              actions: { delete: {} }
            }
          }
        }
      }
    )
    Rails.logger.info("ILM policy '#{policy_name}' created or updated.")

    # 2. Apply index template (can update if already exists)
    template_generator = SearchElastic::Template.new("*#{index_name}*")
    client.indices.put_template(
      name: index_name,
      body: template_generator.body,
      create: false,
      include_type_name: false,
      order: 0
    )
    Rails.logger.info("Index template for '#{index_name}' applied.")

    if client.indices.exists?(index: index_name)
      Rails.logger.info("Index '#{index_name}' already exists. Ensuring ILM policy is attached.")

      # 3a. Attach ILM policy to existing index if needed
      current_settings = client.indices.get_settings(index: index_name)
      lifecycle = current_settings.dig(index_name, 'settings', 'index', 'lifecycle', 'name')

      if lifecycle != policy_name
        client.indices.put_settings(
          index: index_name,
          body: {
            index: {
              lifecycle: {
                name: policy_name
              }
            }
          }
        )
        Rails.logger.info("ILM policy '#{policy_name}' attached to existing index '#{index_name}'.")
      else
        Rails.logger.info("ILM policy '#{policy_name}' is already applied to index '#{index_name}'.")
      end
    else
      # 3b. Create index with ILM policy
      client.indices.create(
        index: index_name,
        body: {
          settings: {
            index: {
              lifecycle: {
                name: policy_name
              }
            }
          }
        }
      )
      Rails.logger.info("Index '#{index_name}' created with ILM policy '#{policy_name}'.")
    end

    # 4. Wait for index to reach yellow or green status
    client.cluster.health(
      index: index_name,
      wait_for_status: 'yellow',
      timeout: '30s'
    )
  rescue => e
    Rails.logger.error("Failed to create/configure index '#{index_name}': #{e.class} - #{e.message}")
    raise
  end
end
