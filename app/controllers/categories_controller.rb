class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[ show edit update destroy ]

  # GET /categories
  def index
    @categories = Category.available_to(current_user).order(:name)
  end

  # GET /categories/1
  def show
    # Optional: show expenses in this category?
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
    authorize_category_management!(@category)
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    # Logic for assignment
    if current_user.admin?
      # Admins can set global flag via params, or default to global?
      # Let's rely on params, but default user to nil or current_user.
      @category.user = current_user unless @category.global?
    else
      @category.user = current_user
      @category.global = false
    end

    if @category.save
      redirect_to categories_path, notice: "Category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    authorize_category_management!(@category)

    if @category.update(category_params)
      redirect_to categories_path, notice: "Category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /categories/1
  def destroy
    authorize_category_management!(@category)

    # Check if used?
    # dependent: :nullify is set in model. It will set expense category_id to null.
    # We might want to warn user?
    # For now standard destroy.
    @category.destroy
    redirect_to categories_path, notice: "Category was successfully destroyed.", status: :see_other
  end

  private
    def set_category
      @category = Category.find(params[:id])
      # Ensure visibility
      unless Category.available_to(current_user).exists?(@category.id)
        redirect_to categories_path, alert: "You do not have access to this category."
      end
    end

    def category_params
      permitted = [ :name ]
      permitted << :global if current_user.admin?
      params.require(:category).permit(permitted)
    end

    def authorize_category_management!(category)
      allowed = false
      if current_user.admin?
        allowed = true
      elsif category.user_id == current_user.id
        allowed = true
      end

      unless allowed
        redirect_to categories_path, alert: "You are not authorized to manage this category."
      end
    end
end
