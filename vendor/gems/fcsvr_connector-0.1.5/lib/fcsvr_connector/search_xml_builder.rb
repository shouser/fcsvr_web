module FcsvrConnector
  class SearchXmlBuilder
    @search_criteria
  
    def initialize
      @search_criteria = Array.new
    end
  
    def addSearchCriteria(id, value, type, op="eq", offset = 0)
      @search_criteria.push(SearchCriteria.new(id, value, type, op, offset))
    end
    
    def addTimeSearchCriteria(id, anchor_time, op, offset_in_minutes = 0)
      if formatted_anchor_time = reformat_date(anchor_time)
        self.addSearchCriteria(id, formatted_anchor_time, (formatted_anchor_time == "now" ? "atom" : "timestamp"), op, offset_in_minutes*60)
      else
        puts "Date Time format was not recognized so SearchCriteria was not added"
      end
    end
    
    def reformat_date(date)
      case date
      when /^\d{2}\/\d{2}\/\d{4}\s\d{2}:\d{2}:\d{2}$/; return DateTime.strptime(date+DateTime.now.zone, "%m/%d/%Y %H:%M:%S%Z").rfc3339.to_s.gsub(/\+00:00$/, "Z")
      when /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{2}\s\d{2}:\d{2}:\d{2}\s[A-Z]{3}\s\d{4}$/; return DateTime.strptime(date, "%a %b %d %H:%M:%S %Z %Y").rfc3339.to_s.gsub(/\+00:00$/, "Z")
      when /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun),\s\d{2}\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{4}\s\d{2}:\d{2}:\d{2}\s[A-Z]{3}$/; return DateTime.strptime(date,"%a, %d %b %Y %H:%M:%S %Z").rfc3339.to_s.gsub(/\+00:00$/, "Z")
      when /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/; return DateTime.strptime(date).rfc3339.to_s.gsub(/\+00:00$/, "Z")
      when /^now$/; return "now"
      else; return false
      end
    end
    
    def to_xml
      if @search_criteria.empty? then
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.session
        end
        builder.to_xml
      else
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.session {
            xml.values {
              xml.value(:id => "CRIT_TYPE") {
                xml.int 3
              }
              xml.value(:id => "CRIT_INTERSECT") {
                xml.valuesList {
                  @search_criteria.each do |sc|
                    xml.values {
                      if sc.value == "now" then
                        xml.value(:id => "CRIT_CMP_VALUE_OFFSET") {
                          xml.int sc.offset
                        }
                        xml.value(:id => "CRIT_CMP_CALC_VALUE") {
                          xml.value(:id => sc.id) {
                            xml.send(sc.type, sc.value)
                          }
                        }
                      else
                        xml.value(:id => "CRIT_CMP_VALUE") {
                          xml.value(:id => sc.id) {
                           if sc.type == "string" then
                             xml.string('xml:space' => 'preserve') {
                               xml.text sc.value
                             }
                           else
                             xml.send(sc.type, sc.value)
                           end
                          }
                        }
                      end
                      xml.value(:id => "CRIT_CMP_OP") {
                        xml.atom sc.op
                      }
                      xml.value(:id => "CRIT_TYPE") {
                        xml.int 1
                      }
                    }
                  end
                }
              }
            }
          }
        end
        builder.to_xml
      end
    end
  end
end