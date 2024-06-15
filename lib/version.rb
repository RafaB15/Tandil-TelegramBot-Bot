class Version
  MAYOR = 1
  MINOR = 3
  PATCH = 0

  def self.current
    "#{MAYOR}.#{MINOR}.#{PATCH}"
  end
end
