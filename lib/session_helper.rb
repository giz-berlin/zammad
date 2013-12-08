module SessionHelper
  def self.default_collections(user)

    # auto population collections, store all here
    default_collection = {}

    # load collections to deliver from external files
    dir = File.expand_path('../../', __FILE__)
    files = Dir.glob( "#{dir}/app/controllers/sessions/collection_*.rb" )
    for file in files
      load file
      ExtraCollection.session( default_collection, user )
    end

    return default_collection
  end
  def self.push_collections(user)

    # auto population collections, store all here
    push_collections = {}

    # load collections to deliver from external files
    dir = File.expand_path('../../', __FILE__)
    files = Dir.glob( "#{dir}/app/controllers/sessions/collection_*.rb" )
    for file in files
      load file
      ExtraCollection.push( push_collections, user )
    end

    return push_collections
  end

  def self.cleanup_expired

    # web sessions
    ActiveRecord::SessionStore::Session.where('request_type = ? AND updated_at < ?', 1, Time.now - 90.days ).delete_all

    # http basic auth calls
    ActiveRecord::SessionStore::Session.where('request_type = ? AND updated_at < ?', 2, Time.now - 2.days ).delete_all
  end

  def self.get(id)
    ActiveRecord::SessionStore::Session.where( :id => id ).first
  end

  def self.list(limit = 10000)
    ActiveRecord::SessionStore::Session.order('updated_at DESC').limit(limit)
  end

  def self.destroy(id)
    session = ActiveRecord::SessionStore::Session.where( :id => id ).first
    return if !session
    session.destroy
  end
end