Qt.include("../PXApp.js");
Qt.include("../PXStorage.js");
Qt.include("../PXUser.js");
Qt.include("../PXJSONFetcher.js");
Qt.include("../PXStrings.js");

var newsFetcher = (function () {

  var cached_data = {};

  return function (url, callback) {

      if (cached_data[url]) {

          callback(cached_data[url]);

      } else {

          fetcher.get(url, function (results, url) {

              var news_items = [],
                  i = 0,
                  entries = results.responseData.results;

              if (entries.length > 0) {

                  for (i; i < entries.length; i += 1) {

                      news_items.push({
                          "feed_url" : url,
                          "url" : entries[i].unescapedUrl,
                          "title" : html_entity_decode(entries[i].titleNoFormatting, 'ENT_QUOTES'),
                          "source" : html_entity_decode(entries[i].publisher, 'ENT_QUOTES'),
                          "date_str" : entries[i].publishedDate,
                          "date_ts" : Date.parse(entries[i].publishedDate),
                          "image_url" : entries[i].image ? entries[i].image.url : false,
                          "image_width" : entries[i].image ? entries[i].image.tbWidth : false,
                          "image_height" : entries[i].image ? entries[i].image.tbHeight : false,
                      });
                  }
              }

              cached_data[url] = news_items;

              if (callback) {
                  callback(news_items);
              }
          });
      }
  };
}());

var news = (function () {

    var data_key = "current news feeds",
            default_value,
            _current_items = false,
            current_users_values = function () {

                if (!_current_items) {

                    _current_items = valueForKey(currentUser.userId(), data_key);

                    if (!_current_items) {

                        _current_items = {
                            "Local News" : "https://ajax.googleapis.com/ajax/services/search/news?v=1.0&geo=Chicago,%20IL"
                        };
                        setValueForKey(currentUser.userId(), _current_items, data_key);
                    }
                }

                return _current_items;
            };

    return {
        reset: function () {
            _current_items = false;
        },
        currentFeeds: function () {
            return current_users_values();
        },
        // Returns a sorted array of objects, each representing a news object.
        // The returned array will be a list of news items, from most to least
        // recent, from all current news feeds.
        currentItems: function (limit, callback) {

            var current_feeds = this.currentFeeds(),
                num_feeds = Object.keys(current_feeds).length,
                num_feeds_returned = 0,
                sorted_items = [],
                feed_search_terms,
                items_in_feed,
                item_iterator,
                received_items_callback = function (items_in_feed) {

                    sorted_items.push.apply(sorted_items, items_in_feed);
                    num_feeds_returned += 1;

                    // If this is the last feed to return, we can
                    // now sort all the returned items and return them to the
                    // callback
                    if (num_feeds_returned === num_feeds) {

                        sorted_items.sort(function (a, b) {
                            return b.date_ts - a.date_ts;
                        });

                        if (callback) {

                            callback(sorted_items.slice(0, limit));
                        }
                    }
                };

            if (!limit) {
                limit = 10;
            }

            for (feed_search_terms in current_feeds) {

                // We perform all the queries for news items in parallel,
                // but only allow the last one to return feed items
                // to the callback
                newsFetcher(current_feeds[feed_search_terms], received_items_callback);
            }
        },
        addFeed: function (search_term, callback) {

            var current_feeds = current_users_values();

            if (current_feeds[search_term]) {

                callback(false);

            } else {

                current_feeds[search_term] = "https://ajax.googleapis.com/ajax/services/search/news?v=1.0&q=" + encodeURIComponent(search_term);

                // Build up a cache for the news items in this URL
                // immediatly, to make things quicker.
                newsFetcher(current_feeds[search_term]);

                setValueForKey(currentUser.userId(), current_feeds, data_key, callback);
            }
        },
        removeFeed: function (search_term, callback) {

            var current_feeds = current_users_values();

            if (!current_feeds[search_term]) {

                callback(false);

            } else {

                delete current_feeds[search_term];
                setValueForKey(currentUser.userId(), current_feeds, data_key, callback);
            }
        }
    };
}());

var addCurrentUsersNewsFeedsToModel = function (model) {

    var feeds = news.currentFeeds(),
        num_feeds = feeds.length,
        feed_search_terms,
        i = 0;

    for (feed_search_terms in feeds) {

        model.append({
            "rowTextKey" : feed_search_terms
        });
    }
};

var addCurrentUsersNewsItemsToModel = function (model) {

    news.currentItems(20, function (news_items) {

        var i = 0, result;

        for (i; i < news_items.length; i += 1) {

            result = news_items[i];

            model.append({
                "rowTextKey" : result.title,
                "rowNewsUrl" : result.url,
                "rowNewsDate" : result.date_str,
                "rowNewsImageUrl" : result.image_url,
                "rowNewsPublisher" : result.source
            });
        }
    });
};
