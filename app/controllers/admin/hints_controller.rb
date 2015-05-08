class Admin::HintsController < Admin::AdminController
  active_scaffold :hint do |config|
    config.actions = %i(list show)

    config.action_links.add :reload_hints,
                            label: 'Reload from GitHub',
                            position: false,
                            type: :collection

    config.list.sorting = { updated_at: :desc }
  end

  def reload_hints
    result = HintData.reload
    if result && result[:error]
      flash.now[:error] = result[:error]
    else
      flash.now[:info] = 'Reload complete.'
    end
    list
  end
end
