# frozen_string_literal: true

module Admin
  class OdieUrlSourceUpdateController < AdminController
    def index
      @page_title = 'ODIE URL Source Update'
    end

    def affiliate_lookup
      @page_title = 'ODIE URL Source Update'
      @affiliate = Affiliate.find_by(name: params[:affiliate_name])
      if @affiliate
        respond_to do |format|
          format.html { render :index }
        end
      else
        flash[:error] = t('admin.odie_url_source_update.index.no_affiliate', scope: 'super_admin', affiliate_name: params[:affiliate_name])
        redirect_to admin_odie_url_source_update_index_path
      end
    end

    def update_job
      affiliate = Affiliate.find(params[:affiliate_id])
      enqueue_job(affiliate)
      respond_to do |format|
        flash[:success] = t('admin.odie_url_source_update.index.job_enqueued', scope: 'super_admin', affiliate_name: affiliate.name)
        format.html { render :index }
      end
    end

    private

    def enqueue_job(affiliate)
      OdieUrlSourceUpdateJob.perform_later(affiliate: affiliate)
    end
  end
end
