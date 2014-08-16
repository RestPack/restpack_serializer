# restpack_serializer
[![Build Status](https://travis-ci.org/RestPack/restpack_serializer.png?branch=master)](https://travis-ci.org/RestPack/restpack_serializer) [![Code Climate](https://codeclimate.com/github/RestPack/restpack_serializer.png)](https://codeclimate.com/github/RestPack/restpack_serializer) [![Dependency Status](https://gemnasium.com/RestPack/restpack_serializer.png)](https://gemnasium.com/RestPack/restpack_serializer) [![Gem Version](https://badge.fury.io/rb/restpack_serializer.png)](http://badge.fury.io/rb/restpack_serializer) [![Coverage Status](https://coveralls.io/repos/RestPack/restpack_serializer/badge.png?branch=coveralls)](https://coveralls.io/r/RestPack/restpack_serializer?branch=coveralls)

**Model serialization, paging, side-loading and filtering**

restpack_serializer allows you to quickly provide a set of RESTful endpoints for your application. It is an implementation of the emerging [JSON API](http://jsonapi.org/) standard.

> [Live Demo of RestPack Serializer](http://restpack-serializer-sample.herokuapp.com/)

---

* [An overview of RestPack](http://www.slideshare.net/gavinjoyce/taming-monolithic-monsters)
* [JSON API](http://jsonapi.org/)

## Getting Started

### For rails projects:
After adding the gem `restpack_serializer` to your Gemfile, add this code to `config/initializers/restpack_serializer.rb`:

```ruby
Dir[Rails.root.join('app/serializers/**/*.rb')].each do |path|
  require path
end
```

## Serialization

Let's say we have an `Album` model:

```ruby
class Album < ActiveRecord::Base
  attr_accessible :title, :year, :artist

  belongs_to :artist
  has_many :songs
end
```

restpack_serializer allows us to define a corresponding serializer:

```ruby
class AlbumSerializer
  include RestPack::Serializer
  attributes :id, :title, :year, :artist_id, :href
end
```

`AlbumSerializer.as_json(album)` produces:

```javascript
{
  "id": "1",
  "title": "Kid A",
  "year": 2000,
  "artist_id": 1,
  "href": "/albums/1"
}
```

`as_json` accepts an optional `context` hash parameter which can be used by your Serializers to customize their output:

```ruby
class AlbumSerializer
  include RestPack::Serializer
  attributes :id, :title, :year, :artist_id, :extras
  can_include :artists, :songs
  can_filter_by :year

  def extras
    if @context[:admin?]
      { markup_percent: 95 }
    end
  end
end
```

```ruby
AlbumSerializer.as_json(album, { admin?: true })
```

## Exposing an API

The `AlbumSerializer` provides `page` and `resource` methods which provide paged collection and singular resource GET endpoints.

```ruby
class AlbumsController < ApplicationController
  def index
    render json: AlbumSerializer.page(params)
  end

  def show
    render json: AlbumSerializer.resource(params)
  end
end
```

These endpoint will live at URLs such as `/albums` and `/albums/142857`:

* http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json
* http://restpack-serializer-sample.herokuapp.com/api/v1/albums/4.json

The `AlbumSerializer` also provides a `single` method which will return a serialized resource similar to `as_json` above.

`page`, `resource` and `single` methods take an optional scope argument allowing us to enforce arbitrary constraints:

```ruby
AlbumSerializer.page(params, Albums.where("year < 1950"))
```

In addition to `scope`, all three methods also accept an optional `context` hash:

```ruby
AlbumSerializer.page(params, Albums.where("year < 1950"), { admin?: true })
```

Other features:
 * [Dynamically Include/Exclude Attributes](https://github.com/RestPack/restpack_serializer/blob/master/spec/serializable/serializer_spec.rb#L42)
 * [Custom Attributes Hash](https://github.com/RestPack/restpack_serializer/blob/master/spec/serializable/serializer_spec.rb#L46)

## Paging

Collections are paged by default. `page` and `page_size` parameters are available:

* http://restpack-serializer-sample.herokuapp.com/api/v1/songs.json?page=2
* http://restpack-serializer-sample.herokuapp.com/api/v1/songs.json?page=2&page_size=3

Paging details are included in a `meta` attribute:

http://restpack-serializer-sample.herokuapp.com/api/v1/songs.json?page=2&page_size=3 yields:

```javascript
{
    "songs": [
        {
            "id": "4",
            "title": "How to Dissapear Completely",
            "href": "/songs/4",
            "links": {
                "artist": "1",
                "album": "1"
            }
        },
        {
            "id": "5",
            "title": "Treefingers",
            "href": "/songs/5",
            "links": {
                "artist": "1",
                "album": "1"
            }
        },
        {
            "id": "6",
            "title": "Optimistic",
            "href": "/songs/6",
            "links": {
                "artist": "1",
                "album": "1"
            }
        }
    ],
    "meta": {
        "songs": {
            "page": 2,
            "page_size": 3,
            "count": 42,
            "include": [],
            "page_count": 14,
            "previous_page": 1,
            "next_page": 3,
            "first_href": "/songs?page_size=3",
            "previous_href": "/songs?page_size=3",
            "next_href": "/songs?page=3&page_size=3",
            "last_href": "/songs?page=14&page_size=3"
        }
    },
    "links": {
        "songs.artist": {
            "href": "/artists/{songs.artist}",
            "type": "artists"
        },
        "songs.album": {
            "href": "/albums/{songs.album}",
            "type": "albums"
        }
    }
}
```

URL Templates to related data are included in the `links` element. These can be used to construct URLs such as:

* /artists/1
* /albums/1

## Side-loading

Side-loading allows related resources to be optionally included in a single API response. Valid side-loads can be defined in Serializers by using ```can_include``` as follows:

```ruby
class AlbumSerializer
  include RestPack::Serializer
  attributes :id, :title, :year, :artist_id, :href

  can_include :songs, :artists
end
```

In this example, we are allowing related `songs` and `artists` to be included in API responses. Side-loads can be specifed by using the `include` parameter:

#### No side-loads

* http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json

#### Side-load related Artists

* http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?include=artists

which yields:

```javascript
{
    "albums": [
        {
            "id": "1",
            "title": "Kid A",
            "year": 2000,
            "href": "/albums/1",
            "links": {
                "artist": "1"
            }
        },
        {
            "id": "2",
            "title": "Amnesiac",
            "year": 2001,
            "href": "/albums/2",
            "links": {
                "artist": "1"
            }
        },
        {
            "id": "3",
            "title": "Murder Ballads",
            "year": 1996,
            "href": "/albums/3",
            "links": {
                "artist": "2"
            }
        },
        {
            "id": "4",
            "title": "Curtains",
            "year": 2005,
            "href": "/albums/4",
            "links": {
                "artist": "3"
            }
        }
    ],
    "meta": {
        "albums": {
            "page": 1,
            "page_size": 10,
            "count": 4,
            "include": [
                "artists"
            ],
            "page_count": 1,
            "previous_page": null,
            "next_page": null,
            "first_href": '/albums',
            "previous_href": null,
            "next_href": null,
            "last_href": '/albums'
        }
    },
    "links": {
        "albums.songs": {
            "href": "/songs?album_id={albums.id}",
            "type": "songs"
        },
        "albums.artist": {
            "href": "/artists/{albums.artist}",
            "type": "artists"
        },
        "artists.albums": {
            "href": "/albums?artist_id={artists.id}",
            "type": "albums"
        },
        "artists.songs": {
            "href": "/songs?artist_id={artists.id}",
            "type": "songs"
        }
    },
    "linked": {
        "artists": [
            {
                "id": "1",
                "name": "Radiohead",
                "website": "http://radiohead.com/",
                "href": "/artists/1"
            },
            {
                "id": "2",
                "name": "Nick Cave & The Bad Seeds",
                "website": "http://www.nickcave.com/",
                "href": "/artists/2"
            },
            {
                "id": "3",
                "name": "John Frusciante",
                "website": "http://johnfrusciante.com/",
                "href": "/artists/3"
            }
        ]
    }
}
```

#### Side-load related Songs

* http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?include=songs

An album `:has_many` songs, so the side-loaded songs are paged. The `meta.songs` includes `previous_href` and `next_href` which point to the previous and next page of this side-loaded data. These URLs take the form:

* http://restpack-serializer-sample.herokuapp.com/api/v1/songs.json?album_ids=1,2,3,4&page=2

#### Side-load related Artists and Songs

* http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?include=artists,songs

## Filtering

Simple filtering based on primary and foreign keys is supported by default:

#### By primary key:

 * http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?id=1
 * http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?ids=1,2,4

#### By foreign key:

 * http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?artist_id=1
 * http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?artist_ids=2,3

#### Custom filters:

Custom filters can be defined with the `can_filter_by` option:

 ```ruby
class Account
    include RestPack::Serializer
    attributes :id, :application_id, :created_by, :name, :href

    can_filter_by :application_id
end
```

Side-loading is available when filtering:

 * http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?artist_ids=2,3&include=artists,songs

## Sorting

Sorting attributes can be defined with the `can_sort_by` option:

 ```ruby
class Account
    include RestPack::Serializer
    attributes :id, :application_id, :created_by, :name, :href

    can_sort_by :id, :name
end
```

 * http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?sort=id
 * http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?sort=-name
 * http://restpack-serializer-sample.herokuapp.com/api/v1/albums.json?sort=name,-id

## Running Tests

`bundle`
`rake spec`
