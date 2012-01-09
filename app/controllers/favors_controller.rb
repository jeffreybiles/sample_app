class FavorsController < ApplicationController


  def create
    @god = God.find(params[:favor][:god_id])
    current_user.worship!(@god)

    redirect_to @god
  end

  def update
    @favor = Favor.where(user_id: current_user.id, god_id: params[:favor][:god_id])
    @god = @favor.first.god
    #next challenge:  finding how to make the experience variable.
    #that is to say, how to pull in the challenge level to this controller.
    current_user.add_experience(20, @god)
    redirect_to @god
  end

  def index
    @favors = Favor.all()
  end

  def destroy

  end

  private


end
