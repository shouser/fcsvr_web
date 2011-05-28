module FcsvrConnector
  
  class FcsClient

    @@fcsvr_version = '1.5'
    @@fcsvr_bundle_path = '/Library/Application\ Support/Final\ Cut\ Server/Final\ Cut\ Server.bundle/Contents/MacOS/'
    @@fcsvr_client = 'fcsvr_client'
    @@fcsvr_host = 'cook.local'
    @@sudo = 'sudo '
    @@echo_cmd = '/bin/echo'
    @@fcsvr_client_cmd = "#{@@fcsvr_bundle_path + @@fcsvr_client}"

    def getmd(entity_addr)
      output = IO.popen(@@fcsvr_client_cmd + " getmd --xml " + entity_addr) do |pipe|
        pipe.read
      end
      xml_doc = REXML::Document.new output
      metadata = Hash.new
      REXML::XPath.each(xml_doc, "//session/values/value") do |element|
        metadata[element.attributes["id"]] = element[1].text()
      end
      return metadata
    end
    
    def search(search_xml_builder, container_addr)
      output = IO.popen(@@echo_cmd + " '" + search_xml_builder.to_xml + "' | " + @@fcsvr_client_cmd + " search --xmlcrit --xml " + container_addr) do |pipe|
        pipe.read
      end
      xml_doc = REXML::Document.new output
      #return hash of metadata
      metadata = Hash.new
      metadata["type"] = container_addr.gsub("/", "")
      REXML::XPath.each(xml_doc, "//session/values") do |element|
        element_address = REXML::XPath.first(element, "./value[@id='ADDRESS']/string").text().split("/").last
        metadata[element_address] = Hash.new
        REXML::XPath.each(element, "./value[@id='METADATA']/values/value") do |metadata_element|
          metadata[element_address][metadata_element.attributes["id"]] = metadata_element[1].text()
        end
      end
      return metadata
    end 

  end

end