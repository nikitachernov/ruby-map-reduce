module MapReduce
  ##
  # This class defines a map reduce job
  class Job
    attr_reader :map_function, :reduce_function

    def initialize(map_function, reduce_function)
      @map_function = map_function
      @reduce_function = reduce_function
    end

    def map(data)
      data.each_with_object(Hash.new([])) do |value, hash|
        mapped_data = @map_function.call(value)
        id = mapped_data[:_id]
        hash[id] += [mapped_data]
      end
    end

    def reduce(data)
      data.map do |key, values|
        values.size > 1 ? reduce_function.call(key, values) : values[0]
      end
    end

    def map_reduce(data)
      reduce(map(data))
    end
  end
end
