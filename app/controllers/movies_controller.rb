class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create
    external_id = params[:external_id]

    begin
      movie = MovieWrapper.find(external_id)
      if movie
        movie.save!
        render status: :created, json: {}
      else
        render status: :not_found, json: { errors: { external_id: ["no movie with ID #{external_id}"]}}
      end
    rescue MovieWrapper::DuplicateMovieException
      render status: :bad_request, json: { errors: { external_id: ["Movie #{external_id} is already in the database"]}}
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
