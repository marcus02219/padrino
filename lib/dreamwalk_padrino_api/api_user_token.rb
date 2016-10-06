require 'uuidtools'

class ApiUserToken < Sequel::Model

  unrestrict_primary_key
  plugin(:timestamps, update_on_create: true)
  plugin(:paranoid)
  plugin(:association_dependencies)
  plugin(:skip_create_refresh)

  many_to_one :user
  one_to_many :api_requests

  add_association_dependencies api_requests: :destroy

  def self.issue(user)
    create(id: UUIDTools::UUID.random_create.to_s, user: user).refresh
  end

end
