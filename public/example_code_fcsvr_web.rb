require 'net/http'
require 'uri'
require 'JSON'

$rest_hostname = "localhost"

def test_get_metadata
  # Pulling Metadata for projects and assets
  # Example pulling JSON for asset
  puts "JSON Ouptut for pulling metadata for an asset:"
  uri = URI.parse("http://#{$rest_hostname}:3000/entity/show/asset/1.json")
  Net::HTTP.get_print(uri)
  puts "\n\n"

  # Example pulling XML for asset
  puts "XML Ouptut for pulling metdata for an asset:"
  uri = URI.parse("http://#{$rest_hostname}:3000/entity/show/asset/1.xml")
  Net::HTTP.get_print(uri)
  puts "\n\n"

  # Example pulling JSON for project
  puts "JSON Ouptut for pulling metdata for a project:"
  uri = URI.parse("http://#{$rest_hostname}:3000/entity/show/project/1.json")
  Net::HTTP.get_print(uri)
  puts "\n\n"

  # Example pulling XML for project
  puts "XML Ouptut for pulling metdata for a project:"
  uri = URI.parse("http://#{$rest_hostname}:3000/entity/show/project/1.xml")
  Net::HTTP.get_print(uri)
  puts "\n\n"
end

def test_get_project_tree
  # Pulling the full addresses of the full heirarchy of a project address
  # Example pulling JSON
  puts "JSON Ouptut for pulling a project tree:"
  uri = URI.parse("http://#{$rest_hostname}:3000/project/get_tree/1.json")
  Net::HTTP.get_print(uri)
  puts "\n\n"

  # Example pulling XML
  puts "XML Ouptut for pulling a project tree:"
  uri = URI.parse("http://#{$rest_hostname}:3000/project/get_tree/1.xml")
  Net::HTTP.get_print(uri)
  puts "\n\n"
end

def test_get_asset_file_reps
  # Pulling the file representations and proxies for an asset with their full pathing
  # Example pulling JSON
  puts "JSON Ouptut for pulling all asset file representations:"
  uri = URI.parse("http://#{$rest_hostname}:3000/asset/get_rep_links/1.json")
  Net::HTTP.get_print(uri)
  puts "\n\n"

  # Example pulling XML
  puts "XML Ouptut for pulling all asset file representations:"
  uri = URI.parse("http://#{$rest_hostname}:3000/asset/get_rep_links/1.xml")
  Net::HTTP.get_print(uri)
  puts "\n\n"
end

def test_set_metadata
  # Setting metadata on an asset or a project
  # Set metadata to a field on an asset and output the metadata on the asset returned to check whether the field is set properly
  puts "Setting metadata field for an asset"
  setmd_json = '{"CUST_KEYWORDS":{"value":"traffic,thinkstock,no-audio227,another,yetanother,argh,blag berg","type":"string"}}'
  uri = URI.parse("http://#{$rest_hostname}:3000/entity/update/asset/1.json")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 6000
  request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' => 'application/json'})
  request.body = setmd_json
  response = http.request(request)
  puts response.body
  
  # Set metadata to a field on a project then read back the meatadata to see if the field was correctly set
  puts "Setting metadata field for a project"
  setmd_json = '{"CUST_TITLE":{"value":"test project2","type":"string"}}'
  uri = URI.parse("http://#{$rest_hostname}:3000/entity/update/project/1.json")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 6000
  request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' => 'application/json'})
  request.body = setmd_json
  response = http.request(request)
  puts response.body
  
end

def test_create_asset
  # Create assets with 2 basic metadata fields.  Assets must reside on a direct pathable location on the Final Cut Server and must not have a single quote in their name
  asset_creation_hash = {
    "source_file_path" => "/Volumes/Storage/",
    "source_file_name" => "V0035744& \#@([^%!test ;'<>blah.mov",
    "asset_type" => "pa_asset_media",
    "device_addr" => "/dev/6",
    "remove_original_file" => false,
    "trigger_analyze" => true,
    "description" => nil,
    "keywords" => "",
    "project_addr" => ""
  }
  
  puts "Create an asset and output the metadata that is returned for the created asset"
  uri = URI.parse("http://#{$rest_hostname}:3000/asset/create.json")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 6000
  request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' => 'application/json'})
  request.body = asset_creation_hash.to_json
  response = http.request(request)
  puts response.body
end

def test_create_asset_with_rep_links
  asset_with_rep_links_hash_json = {
    "asset_type" => "pa_asset_media",
    "version_asset" => "true",
    "cust_title" => "Test 10",
    "representations" => [
        {
          "uri" => "file://localhost/Volumes/StorageRAID/FCSvr_Stuff/FCSvr_Data/Production_Media/Media/test10.mov",
          "device_name" => "Media",
          "rep_link_type" => "HasPrimaryRep",
          "proxy_persistence" => nil
        },
        {
          "uri" => "file://localhost/Volumes/StorageRAID/FCSvr_Stuff/FCSvr_Data/Proxies/Proxies_FS.bundle/manual_assets/test10/thumbnail.jpg",
          "device_name" => "Proxies_FS",
          "rep_link_type" => "HasThumbnailProxy",
          "proxy_persistence" => "Permanent"
        },
        {
          "uri" => "file://localhost/Volumes/StorageRAID/FCSvr_Stuff/FCSvr_Data/Proxies/Proxies_FS.bundle/manual_assets/test10/frame.jpg",
          "device_name" => "Proxies_FS",
          "rep_link_type" => "HasFrameProxy",
          "proxy_persistence" => "Permanent"
        },
        {
          "uri" => "file://localhost/Volumes/StorageRAID/FCSvr_Stuff/FCSvr_Data/Proxies/Proxies_FS.bundle/manual_assets/test10/clip_proxy.mov",
          "device_name" => "Proxies_FS",
          "rep_link_type" => "HasClipProxy",
          "proxy_persistence" => "Permanent"
        }
      ]
    }.to_json
    
    puts "JSON Ouptut creating an asset with representation links in a json post:"
    uri = URI.parse("http://#{$rest_hostname}:3000/asset/create_with_rep_links.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 6000
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' => 'application/json'})
    request.body = asset_with_rep_links_hash_json
    response = http.request(request)
    puts response.body
end

def test_search
  # Allows for searching on assets or projects
  # Search for an asset using a few metadata fields
  puts "Search for an asset using a precise metadata field"
  search_json = '{"search":{"type":"interesect","criteria":[{"name":"ASSET_NUMBER","op":"eq","data_type":"bigint","value":1,"offset":0}]}}'
  puts "JSON Ouptut for pulling matches to search:"
  uri = URI.parse("http://#{$rest_hostname}:3000/search/asset.json")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 6000
  request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' => 'application/json'})
  request.body = search_json
  response = http.request(request)
  puts response.body
  
  # Search for all assets using a time based criteria (should return a ton of stuff)
  puts "Search for all assets using a time period based field"
  search_json = '{"search":{"type":"interesect","criteria":[{"name":"FILE_CREATE_DATE","op":"gt","data_type":"atom","value":"now","offset":-6000000}]}}'
  puts "JSON Ouptut for pulling matches to search:"
  uri = URI.parse("http://#{$rest_hostname}:3000/search/asset.json")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 6000
  request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' => 'application/json'})
  request.body = search_json
  response = http.request(request)
  puts response.body
  
  # Search for all projects using a time based criteria (should return a ton of stuff)
  puts "Search for all projects using a time period based field"
  search_json = '{"search":{"type":"interesect","criteria":[{"name":"ENTITY_CREATED","op":"gt","data_type":"atom","value":"now","offset":-60000000}]}}'
  puts "JSON Ouptut for pulling matches to search:"
  uri = URI.parse("http://#{$rest_hostname}:3000/search/project.json")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 6000
  request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' => 'application/json'})
  request.body = search_json
  response = http.request(request)
  puts response.body
end

test_get_metadata
test_get_project_tree
test_get_asset_file_reps
test_set_metadata
test_create_asset
test_create_asset_with_rep_links
test_search