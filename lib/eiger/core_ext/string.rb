# String monkey-patch
class String
  def camelize
    # rubocop:disable PerlBackrefs
    self.gsub!(/(_|)([a-z\d]*)/i) { $2.capitalize }
  end
end
