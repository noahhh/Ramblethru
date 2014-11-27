require "instagram"

class DiscoversController < ApplicationController

  before_action :set_discover, only: [:show]

  def new
    @discover = Discover.new
  end

  def create
    @discover = Discover.new(discover_params)
    if @discover.save
      redirect_to @discover
      flash[:notice] = 'Discover page was successfully created.'
    else
      render :new
    end
  end

  def show
    #Yelp
    params = { term: 'food',
               limit: 5,
    }
    @yelp = Yelp.client.search("#{@discover.destination}", params)

    #Instagram
    instagram = HTTParty.get("https://api.instagram.com/v1/media/search?lat=#{@discover.latitude}&lng=#{@discover.longitude}&count=8&client_id=ea93d7b97c444c9bbfcf23cbbcb63ee4")
    instagram_data = JSON.parse(instagram.body)
    @instagram_images = instagram_data["data"]
    # [0]["images"]["thumbnail"]["url"]

    #Reddit
    reddit = HTTParty.get("http://www.reddit.com/r/subreddit/search.json?q=#{@discover.destination}&limit=5&sort=top")
    reddit_data = JSON.parse(reddit.body)
    @reddit_thread = reddit_data["data"]["children"]

    #Foursquare
    foursquare = HTTParty.get("http://api.foursquare.com/v2/venues/explore?ll=#{@discover.latitude},#{@discover.longitude}&limit=5&oauth_token=3SFP4NBFWJ2LIECDWGR5EU4FA5QXMP21LK2DNWT2GEUWCEIN&v=20141123")
    foursquare_data = JSON.parse(foursquare.body)
    @foursquare_venue = foursquare_data["response"]["groups"][0]["items"]
    @foursquare_tip = foursquare_data["response"]["groups"][0]["items"]
    @foursquare_venue_url = foursquare_data["response"]["groups"][0]["items"][0]["venue"]["name"]
  end

  def create_ramble
    @ramble = Ramble.new(ramble_params)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_discover
    @discover = Discover.find(params[:id])
  end

  def discover_params
    params.require(:discover).permit(:destination, :latitude, :longitude)
  end
end
