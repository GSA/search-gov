class I14yDrawerObserver < ActiveRecord::Observer

  def before_create(i14y_drawer)
    i14y_drawer_json = I14yCollections.create(i14y_drawer.handle, i14y_drawer.token)
    Rails.logger.debug i14y_drawer_json
    i14y_drawer_json.status == 200
  rescue => e
    Rails.logger.warn("Trouble linking up I14y drawer #{i14y_drawer.handle}: #{e}")
    false
  end

  def before_destroy(i14y_drawer)
    i14y_drawer_json = I14yCollections.delete(i14y_drawer.handle)
    Rails.logger.debug i14y_drawer_json
    i14y_drawer_json.status == 200
  rescue => e
    Rails.logger.warn("Trouble destroying I14y drawer #{i14y_drawer.handle}: #{e}")
    false
  end
end
