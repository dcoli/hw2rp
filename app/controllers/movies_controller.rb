class MoviesController < ApplicationController

  attr_accessor :hilite_title
  attr_accessor :hilite_release_date

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if(params[:sortby]=='title')
      self.hilite_title = true
      self.hilite_release_date = false
      @movies = Movie.order("title asc")
    elsif(params[:sortby]=='release_date')
      self.hilite_title = false
      self.hilite_release_date = true
      @movies = Movie.order("release_date asc")
    else
      self.hilite_title = false
      self.hilite_release_date = false
      @movies = Movie.all
    end
  end

  def index_by_title
    self.hilite_title = true
    self.hilite_release_date = false
    @movies = Movie.all_by_title
  end

  def index_by_release_date
    self.hilite_title = false
    self.hilite_release_date = true
    @movies = Movie.all_by_release_date
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
