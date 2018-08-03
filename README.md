```
$ brew tap shopify/shopify
$ brew install toxiproxy
$ toxiproxy-server
$ docker run -d --hostname sweatshop-1 --name sweatshop-1 -p 15672:15672 -p 5672:5672 rabbitmq:3-management
$ bundle install
$ bundle exec ruby app.rb
```
