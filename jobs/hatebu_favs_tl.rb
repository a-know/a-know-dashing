# encoding: utf-8

require 'rss'

# Specify user name you want to display Hatena Bookmark favorites bookmarks.
user = 'a-know'
# Specify the limit size of the list to be displayed.
limit_size = 5

class HatebuFavsRss
  def initialize(user)
    @user = user
  end

  def items
    items = RSS::Parser.parse("http://b.hatena.ne.jp/#{@user}/favorite.rss?date=#{Time.now.to_i}").items
  end
end

class Bookmark
  def initialize(bookmark)
    @bookmark = bookmark
  end

  def user
    @bookmark.about =~ /b\.hatena\.ne\.jp\/([^\/]+)/
    $1
  end

  def icon
    @bookmark.content_encoded =~ /img src="([^"]+)" class="profile-image"/
    $1
  end

  def comment
    (@bookmark.description.nil? || @bookmark.description.empty?) ? '（no comments）' : @bookmark.description
  end

  def ago
    sec = (Time.now - @bookmark.dc_date).floor
    if sec < 3600
      sec = sec / 60
      "#{sec} minutes ago"
    elsif sec > 3600 && sec < 86400
      hour = sec / 60 / 60
      "#{hour} hours ago"
    else
      day = sec / 60 / 60 / 24
      "#{day} days ago"
    end
  end

  def target_favicon
    @bookmark.content_encoded =~ /img src="([^"]+)" alt=/
    $1
  end

  def target_title
    @bookmark.title
  end
end

SCHEDULER.every '5m', :first_in => 0 do
  rss = HatebuFavsRss.new(user)
  items = rss.items.map do |item|
    bookmark = Bookmark.new(item)
    {
      comment:  bookmark.comment,
      user:     bookmark.user,
      icon_url: bookmark.icon,
      ago:      bookmark.ago,
      title:    bookmark.target_title,
      favicon:  bookmark.target_favicon,
    }
  end

  send_event('hatebu_favs_tl', {items: items[0..limit_size-1]}) unless items.empty?
end