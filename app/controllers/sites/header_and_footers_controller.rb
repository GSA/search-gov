class Sites::HeaderAndFootersController < Sites::SetupSiteController
  SIMPLE_MODE = 'simple'.freeze
  ADVANCED_MODE = 'advanced'.freeze
  MODES = [SIMPLE_MODE, ADVANCED_MODE].freeze

  before_action :assign_mode
  before_action :build_header_links, only: [:edit, :new_header_link]
  before_action :build_footer_links, only: [:edit, :new_footer_link]

  def edit
  end

  def new_header_link
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def new_footer_link
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def update
    simple_mode? ? update_header_footer_links : update_custom_header_footer
  end

  def update_header_footer_links
    @site.staged_uses_managed_header_footer = true
    @site.uses_managed_header_footer = true
    @site.has_staged_content = false

    if @site.update_attributes(simple_mode_site_params)
      redirect_to edit_site_header_and_footer_path(@site),
                  flash: { success: 'You have updated your header and footer information.' }
    else
      build_header_links
      build_footer_links
      render :edit
    end
  end

  def update_custom_header_footer
    if params[:commit] == 'Make Live'
      if @site.update_attributes_for_live(advanced_mode_site_params)
        Emailer.affiliate_header_footer_change(@site).deliver_now if @site.has_changed_header_or_footer
        redirect_to edit_site_header_and_footer_path(@site),
                    flash: { success: 'You have saved header and footer changes to your live site.' }
      else
        render :edit
      end
    elsif params[:commit] == 'Save for Preview'
      if @site.update_attributes_for_staging(advanced_mode_site_params)
        redirect_to edit_site_header_and_footer_path(@site),
                    flash: { success: 'You have saved header and footer changes for preview.' }
      else
        render :edit
      end
    elsif params[:commit] == 'Cancel Changes'
      @site.cancel_staged_changes
      redirect_to edit_site_header_and_footer_path(@site),
                  flash: { success: 'You have cancelled header and footer changes.' }
    end
  end

  private

  def assign_mode
    @mode = params[:mode] if MODES.include? params[:mode]
    @mode = SIMPLE_MODE if @site.force_mobile_format?
    @mode ||= @site.staged_uses_managed_header_footer? ? SIMPLE_MODE : ADVANCED_MODE
  end

  def simple_mode?
    SIMPLE_MODE == @mode
  end

  def build_header_links
    @site.managed_header_links = [{}] if @site.managed_header_links.blank?
  end

  def build_footer_links
    @site.managed_footer_links = [{}] if @site.managed_footer_links.blank?
  end

  def simple_mode_site_params
    simple_mode_params = params.require(:site).
      permit({ css_property_hash: %i(menu_button_alignment) },
             :header_tagline,
             :header_tagline_url,
             :mark_header_tagline_logo_for_deletion,
             :header_tagline_logo,
             { managed_footer_links_attributes: %i(position title url) },
             { managed_header_links_attributes: %i(position title url) })
    simple_mode_params[:css_property_hash] &&= @site.css_property_hash.merge(simple_mode_params[:css_property_hash])
    simple_mode_params
  end

  def advanced_mode_site_params
    params.require(:site).permit(:staged_footer,
                                 :staged_header,
                                 :staged_header_footer_css).
        merge(staged_uses_managed_header_footer: '0')
  end
end
