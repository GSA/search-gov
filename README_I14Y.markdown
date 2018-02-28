#Local i14y setup

For a general overview of i14y drawers, start with the
[manual](https://search.gov/manual/i14y-drawers.html) and the
[technical documentation](https://gsa.github.io/slate).

##Set up i14y
To get it hooked into your local usasearch, follow these steps:

1. Clone the [i14y repo](https://github.com/GSA/i14y), and follow the
   setup instructions on the i14y readme.
1. Fire it up: `rails s -p 8081` (the port just needs to match the port in
   the i14y entry for usasearch's config/secrets.yml)

##Enable i14y in usasearch
The development database is seeded with an i14-enabled affiliate. To
create additional i14y affiliates manually, follow these steps:
1. In usasearch, navigate to the Super Admin editing page for your site (/admin/affiliates).
1. In the Enable/disable Settings section, check 'Gets i14y results'.
   Save changes.
1. Follow the steps in https://search.gov/manual/i14y-drawers.html to add a drawer to your site.

To view the secret token for a drawer, run 'i14y_drawer.token' in the
console, or navigate to /sites/5/i14y_drawers > Show.

##Add some i14y content
Issue curl commands to your i14y port per https://gsa.github.io/slate/#create-a-document to
add some documents to your drawer.
```
curl "http://localhost:8081/api/v1/documents" \
  -XPOST \
  -H "Content-Type:application/json" \
  -u "your_drawer_handle":"your_secret_token" \
  -d '{"document_id":"2",
      "title":"Another doc about rutabagas",
      "path": "http://www.gov.gov/cms/doc2.html",
      "created": "2015-05-12T22:35:09Z",
      "description":"Lots of very important info on rutabagas",
      "content":"rutabagas",
      "promote": false,
      "language" : "en",
      "tags" : "tag1, another tag"
      }'
```

##Profit
Searches for 'rutabaga' for that affiliate should now return results.
