module Organized
  class StickersController < Organized::BaseController
    include SortableTable
    before_action :ensure_access_to_bike_stickers!, except: [:create] # Because this checks ensure_admin
    before_action :find_bike_sticker, only: [:edit, :update]

    def index
      page = params[:page] || 1
      per_page = params[:per_page] || 25
      @bike_stickers = searched.includes(:bike)
        .reorder("bike_stickers.#{sort_column} #{sort_direction}")
        .page(page).per(per_page)
    end

    def edit
    end

    # This is exactly the same as BikeStickersController#update - except the redirect is different
    def update
      bike_id = params[:bike_id].present? ? params[:bike_id] : params.dig(:bike_sticker, :bike_id)
      @bike_sticker.claim_if_permitted(user: current_user, bike: bike_id, organization: current_organization)
      if @bike_sticker.errors.any?
        flash[:error] = @bike_sticker.errors.full_messages.to_sentence
      else
        flash[:success] = "#{@bike_sticker.kind.titleize} #{@bike_sticker.code} - #{@bike_sticker.claimed? ? "claimed" : "unclaimed"}"
        if @bike_sticker.bike.present?
          redirect_to(bike_path(@bike_sticker.bike_id)) && return
        end
      end
      redirect_back(
        fallback_location: edit_organization_sticker_path(
          organization_id: current_organization.to_param,
          id: @bike_sticker.code
        )
      )
    end

    private

    def sortable_columns
      %w[created_at claimed_at code_integer]
    end

    def bike_sticker_code
      params.dig(:bike_sticker, :code) || params[:id]
    end

    def find_bike_sticker
      bike_sticker = BikeSticker.lookup_with_fallback(bike_sticker_code, organization_id: current_organization.id, user: current_user)
      # use the loosest lookup
      @bike_sticker = bike_sticker if bike_sticker.present?
      return @bike_sticker if @bike_sticker.present?
      flash[:error] = translation(:unable_to_find_sticker, bike_sticker: bike_sticker_code)
      redirect_to(organization_stickers_path(organization_id: current_organization.to_param)) && return
    end

    def searched
      searched_codes = BikeSticker.where(organization_id: current_organization.id)
      if params[:search_bike].present?
        searched_codes = searched_codes.claimed.where(bike_id: Bike.friendly_find(params[:search_bike])&.id)
      elsif params[:search_claimedness] && params[:search_claimedness] != "all"
        searched_codes = params[:search_claimedness] == "claimed" ? searched_codes.claimed : searched_codes.unclaimed
      end
      searched_codes.admin_text_search(params[:query])
    end

    def ensure_access_to_bike_stickers!
      return true if current_organization.enabled?("bike_stickers") || current_user.superuser?
      flash[:error] = translation(:org_does_not_have_access)
      redirect_to(organization_bikes_path(organization_id: current_organization.to_param)) && return
    end
  end
end
