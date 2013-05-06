# restpack-serializer [![Build Status](https://travis-ci.org/RestPack/restpack-serializer.png?branch=master)](https://travis-ci.org/RestPack/restpack-serializer) [![Code Climate](https://codeclimate.com/github/RestPack/restpack-serializer.png)](https://codeclimate.com/github/RestPack/restpack-serializer) [![Dependency Status](https://gemnasium.com/RestPack/restpack-serializer.png)](https://gemnasium.com/RestPack/restpack-serializer) [![Gem Version](https://badge.fury.io/rb/restpack-serializer.png)](http://badge.fury.io/rb/restpack-serializer)

## Model serialization, paging, side-loading and filtering

**This is a work in progress**

* [An overview of RestPack](http://goo.gl/rGoIQ)
* [Live restpack-serializer demo](http://restpack-serializer-sample.herokuapp.com/)

**EDIT**: http://jsonapi.org/ has just been released. I'm working on implementing its specification.

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




