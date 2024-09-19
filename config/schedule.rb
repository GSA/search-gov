every 1.month, roles: [:cron] do
  rake 'search:reports:email_monthly_reports'
end

every '35 21 18 12 *', roles: [:cron] do
  rake 'search:reports:email_yearly_reports'
end

every '18 9 * * 1-5', roles: [:cron]  do
  rake 'search:federal_register:import_agencies'
end

every '18 9 * * 1-5', roles: [:cron]  do
  rake 'search:federal_register:import_documents'
end
