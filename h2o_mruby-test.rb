# pseudo database
$DB = [
  { id: 1, key: 'value1' },
  { id: 2, key: 'value2' }
]

class H2oMrubyTest
  class App
    # FIXME: Only one level hash can convert. Write String=>Hash parser...
    def str2hash(str)
      str.gsub(/[\{\}]/, '').split(',').each_with_object({}) do |kv, hash|
        key, value = kv.split(':').map { |s| s.gsub(/[\s"]/, '') }
        hash[key.to_sym] = value
      end
    end

    # CREATE endpoint
    def api_create(_req_query, req_input)
      new_id = $DB.map { |db| db[:id] }.max + 1
      new_datum = { id: new_id }.merge(str2hash(req_input))
      $DB.push(new_datum)
      [201, "CREATED: #{new_datum}"]
    end

    # INDEX / SHOW endpoint
    def api_read(req_query, _req_input)
      if req_query == ''
        [200, $DB]
      else
        queries = req_query.split('&').map{ |q| q.split('=') }
        return [400, 'SHOW: id required'] unless queries.find { |q| q.first == 'id' }
        req_id = queries.find { |q| q.first == 'id' }.last.to_i
        return [404, 'SHOW: not found'] unless $DB.find { |db| db[:id] == req_id }
        [200, $DB.find{ |db| db[:id] == req_id }]
      end
    end

    # UPDATE endpoint
    def api_update(req_query, req_input)
      queries = req_query.split('&').map{ |q| q.split('=') }
      return [400, 'SHOW: id required'] unless queries.find { |q| q.first == 'id' }
      req_id = queries.find { |q| q.first == 'id' }.last.to_i
      return [404, 'SHOW: not found'] unless $DB.find { |db| db[:id] == req_id }
      updated_datum = { id: req_id }.merge(str2hash(req_input))
      $DB.map! { |db| db[:id] == req_id ? updated_datum : db }
      [200, "UPDATED: #{req_id}"]
    end

    # DELTE endpoint
    def api_delete(req_query, _req_input)
      queries = req_query.split('&').map{ |q| q.split('=') }
      return [400, 'SHOW: id required'] unless queries.find { |q| q.first == 'id' }
      req_id = queries.find { |q| q.first == 'id' }.last.to_i
      return [404, 'SHOW: not found'] unless $DB.find { |db| db[:id] == req_id }
      $DB.delete_if { |db| db[:id] == req_id }
      [204, "DELETED: #{req_id}"]
    end

    def routing(req_method, req_path, req_query, req_input)
      res_status, res_body =
        case [req_method, req_path]
        when ['POST', '/api']
          api_create(req_query, req_input)
        when ['GET', '/api']
          api_read(req_query, req_input)
        when ['PUT', '/api']
          api_update(req_query, req_input)
        when ['DELETE', '/api']
          api_delete(req_query, req_input)
        else
          [500, 'WRONG METHOD or API_PATH']
        end

      res_headers = { 'content-type' => 'application/json; charset=utf-9' }
      [res_status, res_headers, [res_body]]
    end

    def call(env)
      req_method = env['REQUEST_METHOD']
      req_path = env['PATH_INFO']
      req_query = env['QUERY_STRING']
      req_input = env['rack.input'] ? env['rack.input'].read : ''
      routing(req_method, req_path, req_query, req_input)
    end
  end
end

H2oMrubyTest::App.new
