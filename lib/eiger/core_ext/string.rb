# String monkey-patch
class String
  def camelize
    self.gsub!(/(_|)([a-z\d]*)/i) { Regexp.last_match[2].capitalize }
  end
end
