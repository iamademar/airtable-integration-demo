class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def index
    User.first.update(synced_at: Time.current)
    @users = User.order(created_at: :desc)
    render json: @users
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :date_of_birth, :uploaded_file)
  end
end
