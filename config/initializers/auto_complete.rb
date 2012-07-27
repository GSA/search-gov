require Rails.root.to_s + "/config/extras/auto_complete/auto_complete"
require Rails.root.to_s + "/config/extras/auto_complete/auto_complete_macros_helper"

ActionController::Base.send :include, AutoComplete
ActionController::Base.helper AutoCompleteMacrosHelper