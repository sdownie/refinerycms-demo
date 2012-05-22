::Refinery::ApplicationController.module_eval do
  def just_installed?
    ::Role[:refinery].users.empty?
  end

  def refinery_user_required?
    if just_installed? and controller_name != 'users'
      redirect_to main_app.new_user_registration_path
    end
  end

  def store_location
    session[:return_to] = request.fullpath.sub("//", "/")
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # This just defines the devise method for after sign in to support
  # extension namespace isolation...
  def after_sign_in_path_for(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    home_path = "#{scope}_root_path"
    respond_to?(home_path, true) ? refinery.send(home_path) : refinery.admin_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    refinery.root_path
  end

  def refinery_user?
    refinery_user_signed_in? && current_refinery_user.has_role?(:refinery)
  end

  def refinery_user_signed_in?
    user_signed_in?
  end

  def authenticate_refinery_user!
    authenticate_user!
  end

  def current_refinery_user
    current_user
  end

  protected :store_location, :redirect_back_or_default, :refinery_user?

  def self.included(base)
    if base.respond_to? :helper_method
      base.send :helper_method, :current_refinery_user, :current_user_session,
                                :refinery_user_signed_in?, :refinery_user?
    end
  end

end
