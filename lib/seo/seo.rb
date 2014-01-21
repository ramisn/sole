module Seo

  module ControllerMethods
    extend ActiveSupport::Concern

    included do
      before_filter :prevent_page_one, :only => [:show, :index]
    end

    module InstanceMethods

      def prevent_page_one
        if params[:page] == '1'
          params.delete(:page)
          redirect_to url_for(params)
        end
      end
    end
  end

  #class SeoLinkRenderer < WillPaginate::ActionView::LinkRenderer
  #  protected
  #
  #  def merge_get_params(url_params)
  #    params = super(url_params)
  #    params.delete(:page) if params[:page] == '1'
  #    params
  #  end
  #
  #  def add_current_page_param(url_params, page)
  #    super(url_params, page)
  #    url_params.delete(:page) if page == 1
  #    url_params
  #  end
  #
  #end

end