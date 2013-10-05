::Refinery::ApplicationController.module_eval do
  require 'refinery/base_presenter'

  def self.included(base) # Extend controller
    base.helper_method :home_page?, :local_request?, :just_installed?,
                       :from_dialog?, :admin?, :login?, :current_refinery_user, :current_user_session,
                       :refinery_user_signed_in?, :refinery_user?

    base.protect_from_forgery # See ActionController::RequestForgeryProtection

    base.send :include, Refinery::Crud # basic create, read, update and delete methods

    if Refinery::Core.rescue_not_found
      base.rescue_from ActiveRecord::RecordNotFound,
                       ::AbstractController::ActionNotFound,
                       ActionView::MissingTemplate,
                       :with => :error_404
    end
  end

  def refinery_user_required?
    if just_installed? and controller_name != 'users'
      redirect_to main_app.new_user_registration_path
    end
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

  def refinery_user_signed_in?
    user_signed_in?
  end

  def authenticate_refinery_user!
    authenticate_user!
  end

  def current_refinery_user
    current_user
  end

    def admin?
      %r{^admin/} === controller_name
    end

    def error_404(exception=nil)
      # fallback to the default 404.html page.
      file = Rails.root.join 'public', '404.html'
      file = Refinery.roots(:'refinery/core').join('public', '404.html') unless file.exist?
      render :file => file.cleanpath.to_s.gsub(%r{#{file.extname}$}, ''),
             :layout => false, :status => 404, :formats => [:html]
      return false
    end

    def from_dialog?
      params[:dialog] == 'true' or params[:modal] == 'true'
    end

    def home_page?
      %r{^#{Regexp.escape(request.path)}} === refinery.root_path
    end

    def just_installed?
      false #Disable redirecting to Authentication engine
    end

    def local_request?
      Rails.env.development? || /(::1)|(127.0.0.1)|((192.168).*)/ === request.remote_ip
    end

    def login?
      (/^(user|session)(|s)/ === controller_name && !admin?) || just_installed?
    end

  protected
    def refinery_user?
      refinery_user_signed_in? && current_refinery_user.has_role?(:refinery)
    end

   # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def store_location
      session[:return_to] = request.fullpath.sub("//", "/")
    end

    # use a different model for the meta information.
    def present(model)
      @meta = presenter_for(model).new(model)
    end

end
