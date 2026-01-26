module SystemAlertsHelper
  def show_system_alerts(system_alerts = nil)
    system_alerts ||= SystemAlert.current
    return if system_alerts.blank?
    content = system_alerts.collect do |system_alert|
      content_tag(:div, system_alert.message.html_safe)
    end
    content_tag(:div, content.join("\n").html_safe, :class => 'notice alert alert-info')
  end
end
