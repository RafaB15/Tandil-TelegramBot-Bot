class Version
  MAYOR = 1
  MINOR = 4
  PATCH = 18

  def self.current
    "#{MAYOR}.#{MINOR}.#{PATCH}"
  end
end
