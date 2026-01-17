class ShoppingListItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_not_admin!
  before_action :set_shopping_list_item, only: %i[ show edit update destroy toggle ]

  def index
    @shopping_list_items = current_user.shopping_list_items.order(completed: :asc, created_at: :desc)
    @new_item = ShoppingListItem.new
  end

  def show
  end

  def new
    @shopping_list_item = current_user.shopping_list_items.build
  end

  def edit
  end

  def create
    @shopping_list_item = current_user.shopping_list_items.build(shopping_list_item_params)

    if @shopping_list_item.save
      redirect_to shopping_list_items_path, notice: "Item added to list."
    else
      @shopping_list_items = current_user.shopping_list_items.order(completed: :asc, created_at: :desc)
      @new_item = @shopping_list_item
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @shopping_list_item.update(shopping_list_item_params)
      redirect_to shopping_list_items_path, notice: "Item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shopping_list_item.destroy
    redirect_to shopping_list_items_path, notice: "Item removed."
  end

  def toggle
    @shopping_list_item.update(completed: !@shopping_list_item.completed)
    redirect_to shopping_list_items_path
  end

  private
    def set_shopping_list_item
      @shopping_list_item = current_user.shopping_list_items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        redirect_to shopping_list_items_path, alert: "Item not found."
    end

    def shopping_list_item_params
      params.require(:shopping_list_item).permit(:name, :completed)
    end

    def ensure_not_admin!
      if current_user.admin?
        redirect_to admin_root_path, alert: "Admins do not need a shopping list."
      end
    end
end
