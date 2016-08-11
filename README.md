# h2o_mruby-test
Simple CRUD APIs with h2o_mruby

# Usage
1. Make h2o with mruby

```
$ cd /path/to/h2o
$ cmake -DWITH_MRUBY=ON .
$ make
```

2. Run h2o

```
$ ./h2o --conf /path/to/here/h2o.conf
$ curl -H "Content-type: application/json" -X GET 'http://127.0.0.1:8080/api'
[{:id=>1, :key=>"new_value"}, {:id=>2, :key=>"value2"}]
```

# API
## READ (index)
```
$ curl -H "Content-type: application/json" -X GET 'http://127.0.0.1:8080/api'
[{:id=>1, :key=>"new_value"}, {:id=>2, :key=>"value2"}]
```

## READ (show)
```
$ curl -H "Content-type: application/json" -X GET 'http://127.0.0.1:8080/api?id=1'
{:id=>1, :key=>"new_value"}

$ curl -H "Content-type: application/json" -X GET 'http://127.0.0.1:8080/api?id=99999'
SHOW: not found
```

## CREATE
```
$ curl -H "Content-type: application/json" -X POST -d '{"key": "NEW_VALUE!"}' 'http://127.0.0.1:8080/api'
CREATED: {:id=>3, :key=>"NEW_VALUE!"}

$ curl -H "Content-type: application/json" -X GET 'http://127.0.0.1:8080/api'
[{:id=>1, :key=>"new_value"}, {:id=>2, :key=>"value2"}, {:id=>3, :key=>"NEW_VALUE!"}]
```

## UPDATE
```
$ curl -H "Content-type: application/json" -X PUT -d '{"key": "UPDATED_VALUE!"}' 'http://127.0.0.1:8080/api?id=1'
UPDATED: 1

$ curl -H "Content-type: application/json" -X GET 'http://127.0.0.1:8080/api'
[{:id=>1, :key=>"UPDATED_VALUE!"}, {:id=>2, :key=>"value2"}]
```

## DELETE
```
$ curl -H "Content-type: application/json" -X DELETE 'http://127.0.0.1:8080/api?id=1'

$ curl -H "Content-type: application/json" -X GET 'http://127.0.0.1:8080/api'
[{:id=>2, :key=>"value2"}]
```
