class Version
  MAYOR = 1
  MINOR = 5
  PATCH = 2

  def self.current
    "#{MAYOR}.#{MINOR}.#{PATCH}"
  end
end
