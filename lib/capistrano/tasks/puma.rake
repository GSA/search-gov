# frozen_string_literal: true

# Traffic on app hosts is served by the Ansible-managed puma.service. The
# Capistrano puma unit fights it for :3000, so Capistrano only restarts
# puma.service, one host at a time so the ALB keeps the rest in service.
namespace :puma do
  desc 'Rolling restart of puma.service and wait for workers on the new release'
  task :restart_service do
    on roles(:app), in: :sequence, wait: fetch(:puma_restart_wait, 30) do |host|
      release = capture(:readlink, '-f', current_path).split('/').last
      execute :sudo, :systemctl, :restart, 'puma.service'

      booted = 60.times.any? do
        sleep 3
        test("pgrep -u #{host.user} -f 'puma: cluster worker.*\\[#{release}\\]' > /dev/null")
      end
      raise "puma.service on #{host} did not boot release #{release}" unless booted

      info "puma.service on #{host} is serving #{release}"
    end
  end
end

after 'deploy:finished', 'puma:restart_service'
