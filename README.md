# restpack-serializer [![Build Status](https://travis-ci.org/RestPack/restpack-serializer.png?branch=master)](https://travis-ci.org/RestPack/restpack-serializer) [![Code Climate](https://codeclimate.com/github/RestPack/restpack-serializer.png)](https://codeclimate.com/github/RestPack/restpack-serializer) [![Dependency Status](https://gemnasium.com/RestPack/restpack-serializer.png)](https://gemnasium.com/RestPack/restpack-serializer) [![Gem Version](https://badge.fury.io/rb/restpack-serializer.png)](http://badge.fury.io/rb/restpack-serializer)

## Model serialization, paging, side-loading and filtering

**This is a work in progress**

* [An overview of RestPack](http://goo.gl/rGoIQ)
* [Live restpack-serializer demo](http://restpack-serializer-sample.herokuapp.com/)

**EDIT**: [JSON API](http://jsonapi.org/) has just been released. I'm working on implementing its specification.

### Serialization

Let's say we have an ```Album``` model as follows:

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
  can_include :songs, :artists

  def href
    "/albums/#{id}.json"
  end
end
```

This serailizer produces JSON in the format (this will soon change to match the [JSON API](http://jsonapi.org/) spec):

```javascript
{
    "albums": [
        {
            "id": 1,
            "title": "Kid A",
            "year": 2000,
            "artist_id": 1,
            "href": "/albums/1.json"
        }
    ]
}
```

### Exposing an API

**Note**: this is subject to change as we implement [JSON API](http://jsonapi.org/)

The ```AlbumSerializer``` provides a ```page``` method which can been used to provide a paged GET collection endpoint.

```ruby
class AlbumSerializer
  include RestPack::Serializer
  attributes :id, :title, :year, :artist_id, :href

  def href
    "/albums/#{id}.json"
  end
end
```

This endpoint will live at a URL similar to ```/albums.json```.

**Demo:** http://restpack-serializer-sample.herokuapp.com/albums.json

### Paging

**Note**: this is subject to change as we implement [JSON API](http://jsonapi.org/)

Collections are paged by default. ```page``` and ```page_size``` parameters are available:

* http://restpack-serializer-sample.herokuapp.com/songs.json?page=2
* http://restpack-serializer-sample.herokuapp.com/songs.json?page=2&page_size=3

### Side-loading

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

In this example, we are allowing related ```songs``` and ```artists``` to be included in API responses. Side-loads can be specifed by using the ```includes``` parameter:

* http://restpack-serializer-sample.herokuapp.com/albums.json (no side-loads)
* http://restpack-serializer-sample.herokuapp.com/albums.json?includes=artists (side-load artists)
* http://restpack-serializer-sample.herokuapp.com/albums.json?includes=songs (side-load songs)
http://restpack-serializer-sample.herokuapp.com/albums.json?includes=artists,songs (side-load both songs and artists)

### Filtering

...




