class RemoteServerJob < ApplicationJob
  queue_as :default

  def perform(commit_hash)
    production? do
      secrets = Rails.application.secrets

      Net::SSH.start(
        secrets.bare_metal_server_ip,
        secrets.bare_metal_server_user,
        password: secrets.bare_metal_server_password
      ) do |ssh|

        ssh.exec!("sudo docker pull tgxworld/rails_bench &&
          sudo docker run --rm -e
          \"RAILS_COMMIT_HASH=#{commit_hash}\" -e
          \"RUBY_VERSION=2.1.5\" -e \"KO1TEST_SEED_CNT=100\"
          tgxworld/rails_bench".squish
        ) do |channel, stream, data|

          puts data
        end
      end
    end
  end
end
