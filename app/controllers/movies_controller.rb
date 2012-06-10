class MoviesController < ApplicationController

  attr_accessor :hilite_title
  attr_accessor :hilite_release_date
  attr_accessor :all_ratings
  attr_accessor :selected_params

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #debugger
    self.all_ratings = Movie.get_ratings
    u = URI.parse(request.env["REQUEST_URI"])
    redirect = false
    #debugger
    #check if params
    puts "sortby=" << params[:sortby].to_s
    puts "ratings=" << params[:ratings].to_s
    #default path but session variables present
    if ( u.query == nil or u.query == "" ) and ( session[:sortby] or session[:ratings] )
      #debugger
      flash[:alert]="using session variables for new index"
      flash.keep
      redirect_to get_redirect_string
    elsif ((params[:sortby] and params[:sortby] != "") or (params[:ratings] and params[:ratings].first != nil))
      #check if new sortby
      if params[:sortby] != session[:sortby]
         session[:sortby] = params[:sortby]
        flash[:alert]="resetting session variables"
        redirect = true
      end
      #check if new ratings
      if params[:ratings] != session[:ratings]
        session[:ratings] = params[:ratings]
        flash[:alert]="resetting session variables"
        redirect = true
      end
      if redirect
        redirect_to get_redirect_string
      end

      #process params
      flash[:alert]="processing params"
      #debugger
      if(session[:sortby]=='title')
        self.hilite_title = true
        self.hilite_release_date = false
        @movies = Movie.order("title asc")
      elsif(session[:sortby]=='release_date')
        self.hilite_title = false
        self.hilite_release_date = true
        @movies = Movie.order("release_date asc")
      else
        self.hilite_title = false
        self.hilite_release_date = false
        @movies = Movie.all
      end
      if session[:ratings] != nil and session[:ratings].first != nil
        @movies = @movies.select do |m|
          match = false
          session[:ratings].keys.each do |r|
            if m[:rating]==r
              match = true
            end
          end
          match
        end
        self.selected_params = ""
        session[:ratings].each do |r|
          self.selected_params << "&ratings[#{r[0]}]=1"
        end
      end

    #default path no session
    else
      self.hilite_title = false
      self.hilite_release_date = false
      @movies = Movie.all
    end
  end

  def get_redirect_string
    redirect_string = ""
    if session[:sortby] == nil or session[:sortby].first == nil
      sortby_string = ''
    else
      sortby_string = 'sortby=' << session[:sortby]
    end
    ratings_string = ''
    if session[:ratings] != nil
      session[:ratings].each do |r|
        ratings_string << "&ratings[#{r[0]}]=#{r[1]}"
      end
    end
    redirect_string = "/movies?" << sortby_string << ratings_string
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
