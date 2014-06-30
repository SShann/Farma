class ApplicationController < ActionController::Base
  protect_from_forgery
  respond_to :json

  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        guest_user.destroy
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  #def current_user
  #  @user ||= User.where(email: "gustavohm98@hotmail.com").first
  #end

  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
  end

  protected

   def ckeditor_filebrowser_scope(options = {})
     super({ :assetable_id => current_user.id, :assetable_type => 'User' }.merge(options))
   end

  private
  def create_guest_user
    u = User.create(name: "Guest", email: "guest_#{Time.now.to_i}#{rand(99)}@example.com", guest: true)
    u.save!(:validate => false)
    session[:guest_user_id] = u.id
    u
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    # Cache the value the first time it's gotten.
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

    rescue Mongoid::Errors::DocumentNotFound # if session[:guest_user_id] invalid
      session[:guest_user_id] = nil
      guest_user
  end
end
