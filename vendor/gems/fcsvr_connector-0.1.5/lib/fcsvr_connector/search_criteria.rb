module FcsvrConnector
  class SearchCriteria
    attr_accessor :id, :value, :type, :op, :offset
    def initialize(id = "", value = "", type = "", op = "eq", offset = 0)
      self.id = id
      self.value = value
      self.type = type
      self.op = op
      self.offset = offset
    end
  end
end