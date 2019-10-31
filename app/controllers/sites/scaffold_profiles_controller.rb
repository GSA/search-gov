require 'active_support/concern'

module Sites::ScaffoldProfilesController
  extend ActiveSupport::Concern
  include Sites::ProfilesController

  included do
    class_eval do
      class_attribute :adapter_klass,
                      :primary_attribute_name,
                      instance_writer: false
    end
  end

  def index
    @profiles = site_profiles
  end

  def new
    @profile = profile_type_klass.send :new
  end

  def create
    @profile = adapter_klass.import_profile create_params[primary_attribute_name]

    unless @profile
      @profile = new_profile_with_not_found_error
      render action: :new and return
    end

    if site_profiles.exists? @profile.id
      @profile = profile_type_klass.new create_params
      flash.now[:notice] = "You have already added #{human_profile_name} to this site."
      render action: :new
    else
      add_profile_to_site
      redirect_to url_for(action: :index),
                  flash: { success: "You have added #{human_profile_name} to this site." }
    end
  end

  def destroy
    @profile = site_profiles.find_by_id destroy_params[:id]
    redirect_to url_for(action: :index) and return unless @profile

    @site.send(pluralized_profile_type).delete(@profile)
    after_profile_deleted
    redirect_to url_for(action: :index), flash: { success: "You have removed #{human_profile_name} from this site." }
  end

  private

  def new_profile_with_not_found_error
    ar = profile_type_klass.new create_params
    ar.errors[primary_attribute_name] = 'is not found'
    ar
  end

  def site_profiles
    @site.send pluralized_profile_type
  end

  def create_params
    @create_params ||= params.require(profile_type).permit(primary_attribute_name).to_h
  end

  def add_profile_to_site
    site_profiles << @profile
  end

  def human_profile_name
    @profile.send primary_attribute_name
  end

  def destroy_params
    params.permit(:id).to_h
  end

  def after_profile_deleted
  end
end
