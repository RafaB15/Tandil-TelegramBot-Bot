class Version
  MAYOR = 1
  MINOR = 2
  PATCH = 1

  def self.current
    "#{MAYOR}.#{MINOR}.#{PATCH}"
  end
end
