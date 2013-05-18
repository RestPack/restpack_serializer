# restpack-serializer [![Build Status](https://travis-ci.org/RestPack/restpack-serializer.png?branch=master)](https://travis-ci.org/RestPack/restpack-serializer) [![Code Climate](https://codeclimate.com/github/RestPack/restpack-serializer.png)](https://codeclimate.com/github/RestPack/restpack-serializer) [![Dependency Status](https://gemnasium.com/RestPack/restpack-serializer.png)](https://gemnasium.com/RestPack/restpack-serializer) [![Gem Version](https://badge.fury.io/rb/restpack-serializer.png)](http://badge.fury.io/rb/restpack-serializer)

**Model serialization, paging, side-loading and filtering**

---

**This is a work in progress**

* [An overview of RestPack](http://goo.gl/rGoIQ)
* [Live restpack-serializer demo](http://restpack-serializer-sample.herokuapp.com/)

**EDIT**: [JSON API](http://jsonapi.org/) has just been released. I'm working on implementing its specification.

## Serialization

Let's say we have an `Album` model:

```ruby
class Album < ActiveRecord::Base
  attr_accessible :title, :year, :artist

  belongs_to :artist
  has_many :songs
end
```

restpack-serializer allows us to define a corresponding serializer:

```ruby
class AlbumSerializer
  include RestPack::Serializer
  attributes :id, :title, :year, :artist_id, :href

  def href
    "/albums/#{id}.json"
  end
end
```

This serailizer produces JSON in the format:

```javascript
{
    "albums": [
        {
            "id": "1",
            "title": "Kid A",
            "year": 2000,
            "artist_id": 1,
            "href": "/albums/1.json"
        }
    ]
}
```

## Exposing an API

The `AlbumSerializer` provides a `page` method which can been used to provide a paged GET collection endpoint.

```ruby
class AlbumsController < ApplicationController
  def index
    render json: AlbumSerializer.page(params)
  end
end
```

This endpoint will live at a URL such as `/albums.json`.

**Demo:** http://restpack-serializer-sample.herokuapp.com/albums.json

The `page` method takes an optional scope which allows us to enforce constraints:

```ruby
AlbumSerializer.page(params, Albums.where("year < 1950"))
```

## Paging

Collections are paged by default. `page` and `page_size` parameters are available:

* http://restpack-serializer-sample.herokuapp.com/songs.json?page=2
* http://restpack-serializer-sample.herokuapp.com/songs.json?page=2&page_size=3

Paging details are included in a `meta` attribute:

http://restpack-serializer-sample.herokuapp.com/songs.json?page=2&page_size=3 yields:

```javascript
{
    "songs": [
        {
            "id": "4",
            "title": "How to Dissapear Completely",
            "href": "/songs/4.json",
            "links": {
                "artist": "1",
                "album": "1"
            }
        },
        {
            "id": "5",
            "title": "Treedfingers",
            "href": "/songs/5.json",
            "links": {
                "artist": "1",
                "album": "1"
            }
        },
        {
            "id": "6",
            "title": "Optimistic",
            "href": "/songs/6.json",
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
            "includes": [],
            "page_count": 14,
            "previous_page": 1,
            "next_page": 3
        }
    },
    "links": {
        "songs.artists": {
            "href": "/artists/{songs.artist}.json",
            "type": "artists"
        },
        "songs.albums": {
            "href": "/albums/{songs.album}.json",
            "type": "albums"
        }
    }
}
```

URL Templates to related data are included in the `links` element. These can be used to construct URLs such as:

* /artists/1.json
* /albums/1.json

## Side-loading

Side-loading allows related resources to be optionally included in a single API response. Valid side-loads can be defined in Serializers by using ```can_include``` as follows:

```ruby
class AlbumSerializer
  include RestPack::Serializer
  attributes :id, :title, :year, :artist_id, :href
  can_include :songs, :artists

  def href
    "/albums/#{id}.json"
  end
end
```

In this example, we are allowing related `songs` and `artists` to be included in API responses. Side-loads can be specifed by using the `includes` parameter:

#### No side-loads

* http://restpack-serializer-sample.herokuapp.com/albums.json

#### Side-load related Artists

* http://restpack-serializer-sample.herokuapp.com/albums.json?includes=artists

which yields:

```javascript
{
    "albums": [
        {
            "id": "1",
            "title": "Kid A",
            "year": 2000,
            "href": "/albums/1.json",
            "links": {
                "artist": "1"
            }
        },
        {
            "id": "2",
            "title": "Amnesiac",
            "year": 2001,
            "href": "/albums/2.json",
            "links": {
                "artist": "1"
            }
        },
        {
            "id": "3",
            "title": "Murder Ballads",
            "year": 1996,
            "href": "/albums/3.json",
            "links": {
                "artist": "2"
            }
        },
        {
            "id": "4",
            "title": "Curtains",
            "year": 2005,
            "href": "/albums/4.json",
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
            "includes": [
                "artists"
            ],
            "page_count": 1,
            "previous_page": null,
            "next_page": null
        }
    },
    "links": {
        "albums.songs": {
            "href": "/songs.json?album_id={albums.id}",
            "type": "songs"
        },
        "albums.artists": {
            "href": "/artists/{albums.artist}.json",
            "type": "artists"
        },
        "artists.albums": {
            "href": "/albums.json?artist_id={artists.id}",
            "type": "albums"
        },
        "artists.songs": {
            "href": "/songs.json?artist_id={artists.id}",
            "type": "songs"
        }
    },
    "artists": [
        {
            "id": "1",
            "name": "Radiohead",
            "website": "http://radiohead.com/",
            "href": "/artists/1.json"
        },
        {
            "id": "2",
            "name": "Nick Cave & The Bad Seeds",
            "website": "http://www.nickcave.com/",
            "href": "/artists/2.json"
        },
        {
            "id": "3",
            "name": "John Frusciante",
            "website": "http://johnfrusciante.com/",
            "href": "/artists/3.json"
        }
    ]
}
```

#### Side-load related Songs

* http://restpack-serializer-sample.herokuapp.com/albums.json?includes=songs

An album `:has_many` songs, so the side-loads are paged. We'll be soon adding URLs to the response meta data which will point to the next page of side-loaded data. These URLs will be something like:

* http://restpack-serializer-sample.herokuapp.com/songs.json?album_ids=1,2,3,4&page=2

#### Side-load related Artists and Songs

* http://restpack-serializer-sample.herokuapp.com/albums.json?includes=artists,songs

## Filtering

Simple filtering based on primary and foreign keys is possible:

#### By primary key:

 * http://restpack-serializer-sample.herokuapp.com/albums.json?id=1
 * http://restpack-serializer-sample.herokuapp.com/albums.json?ids=1,2,4

#### By foreign key:

 * http://restpack-serializer-sample.herokuapp.com/albums.json?artist_id=1
 * http://restpack-serializer-sample.herokuapp.com/albums.json?artist_ids=2,3

Side-loading is available when filtering:

 * http://restpack-serializer-sample.herokuapp.com/albums.json?artist_ids=2,3&includes=artists,songs
