class AdminShopsController < AdminController
  before_action :set_shop, only: %i[edit update destroy remove_image]

  def index
    @shops = RamenShop.order(:name)
    render 'shoplist/admin_index'
  end

  def new
    @shop = RamenShop.new
    render 'shoplist/admin_form'
  end

  def create
    @shop = RamenShop.new(shop_params)
    if @shop.save
      redirect_to admin_shops_path, notice: '店舗を追加しました。'
    else
      render 'shoplist/admin_form', status: :unprocessable_entity
    end
  end

  def edit
    render 'shoplist/admin_form'
  end

  def update
    if @shop.update(shop_params)
      redirect_to admin_shops_path, notice: '店舗情報を更新しました。'
    else
      render 'shoplist/admin_form', status: :unprocessable_entity
    end
  end

  def destroy
    @shop.destroy!
    redirect_to admin_shops_path, notice: '店舗を削除しました。', status: :see_other
  end

  def remove_image
    @shop.image.purge
    redirect_to edit_admin_shop_path(@shop), notice: '一覧画像を削除しました。'
  end

  private

  def set_shop
    @shop = RamenShop.find(params[:id])
  end

  def shop_params
    params.require(:ramen_shop).permit(
      :name, :address, :introduction, :genre, :business_hours,
      :image_url, :detail_image_url, :google_place_id, :image
    )
  end
end
