# restpack-serializer [![Build Status](https://travis-ci.org/RestPack/restpack-serializer.png?branch=master)](https://travis-ci.org/RestPack/restpack-serializer) [![Code Climate](https://codeclimate.com/github/RestPack/restpack-serializer.png)](https://codeclimate.com/github/RestPack/restpack-serializer) [![Dependency Status](https://gemnasium.com/RestPack/restpack-serializer.png)](https://gemnasium.com/RestPack/restpack-serializer) [![Gem Version](https://badge.fury.io/rb/restpack-serializer.png)](http://badge.fury.io/rb/restpack-serializer)

## Model serialization, paging, side-loading and filtering

This is a work in progress.

We want something like this:

```
http://localhost:1111/api/v1/domains.json?includes=applications&page=2&page_size=3
```

```
{
    "applications": [
        {
            "id": 44,
            "name": "Ruby Jobs",
            "url": "/api/v1/applications/44.json",
            "channel_id": 32
        },
        {
            "id": 45,
            "name": "Python Jobs",
            "url": "/api/v1/applications/45.json",
            "channel_id": 32
        }
    ],
    "domains": [
        {
            "id": 86,
            "host": "www.rubyjobs.io",
            "channel_id": 32,
            "application_id": 44,
            "url": "/api/v1/domains/86.json"
        },
        {
            "id": 87,
            "host": "auth.rubyjobs.io",
            "channel_id": 32,
            "application_id": 44,
            "url": "/api/v1/domains/87.json"
        },
        {
            "id": 88,
            "host": "www.pythonjobs.io",
            "channel_id": 32,
            "application_id": 45,
            "url": "/api/v1/domains/88.json"
        }
    ],
    "domains_meta": {
        "page": 2,
        "count": 9,
        "page_size": 3,
        "page_count": 3,
        "previous_page": 1,
        "next_page": 3
    }
}
```

### Questions

1. Where do we specify model serialization
a. RestPack::Serializable. DONE

2. What do we want the controller to look like?
a. def index
    render_page Domain.all, params # /domains.json?includes=applications&page=2&page_size=3
   end

3. What is the responsibility of render_page?
a. validate params?
   call DomainSerializer.page(Domain.all, params)

4. What should Serializer.page(query, params) do?
a. get page of data
b. get a list of related data to fetch:
    1) For has_many:
        - get a page
    2) For belongs_to: <-- More Important
        - get list of relations by distinct ids








