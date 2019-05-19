module Tv
  class Series
    attr_reader :id, :name

    def initialize(id, name)
      @id = id
      @name = name
    end

    def self.all
      [Tv::Series.new(1, 'Jon Snow'),
       Tv::Series.new(2, 'Daenerys Targaryen'),
       Tv::Series.new(3, 'Ned Stark')]
    end

    def self.handle_response(series_id)
      responses = ['Jon es demasiado bueno, nunca lo va a aceptar!',
                   'A mi también me encantan los dragones!',
                   'Ned se murió!']
      responses[series_id.to_i - 1]
    end
  end
end
