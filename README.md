To use the app:
---------------
After `bundle install` run:
`rm -f db/schema.rb; bundle exec rake db:create db:migrate db:seed`
Then run tests by `rake`, `rspec`, or `rspec -fdoc` if you like output in nice documentation format.
Then `bundle exec rails c`, check any email (e.g. with `User.first.email`) and use it to log in with password _asdasdasd_ at `/users/sign_in.html`. Run `bundle exec rake routes` to see all endpoints.  

You can do the same also with json:
-----------------------------------
Create a user:

```
# POST /users
# Content-Type:application/json

{
   "user":{
      "email":"jaime.lannister@casterly.rock",
      "password":"kingslayer",
      "password_confirmation":"kingslayer"
   }
}
```

Log in:

```
# POST /users/sign_in
# Content-Type:application/json

{
   "user":{
      "email":"jaime.lannister@casterly.rock",
      "password":"kingslayer"
   }
}
```
