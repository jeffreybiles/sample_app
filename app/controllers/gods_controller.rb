class GodsController < ApplicationController
  #will need authentication before this goes public.

  def new
    @god = God.new
    @title = "Make a new one!"
  end

  def show
    @god = God.find(params[:id])
    @title = @god.name
  end

  def edit
    @title = "Edit god"
    @god = God.find(params[:id])
    #blasphemy!  Curses upon your house!  Aaaaaaargh!
  end

  def index
    @title = "All gods"
    @gods = God.paginate(:page => params[:page])
  end

  #Look on my works, ye Mighty, and despair
  def destroy
    god = God.find(params[:id])
    god.destroy
    redirect_to gods_path
  end

  def create
    @god = God.new(params[:god])
    @god.max_level = Integer(@god.max_level)
    if @god.save
      flash[:success] = "You've got a motherfucking deity now!"
      redirect_to @god
    else
      @title = "Let's try this shit again."
      render 'new'
    end
  end

  def update
    @god = God.find(params[:id])
    @god.max_level = Integer(@god.max_level)
    if @god.update_attributes(params[:god])
      flash[:success
      ] = "You.... changed a holy god.  You bastard.  Or saint.  I'm not sure."
      redirect_to @god
    else
      @title = "Didn't work out so well for ya, did it?'"
      render 'edit'
    end
  end

end
