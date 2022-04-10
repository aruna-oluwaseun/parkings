class String
  def remove_non_alphanumeric
    self.gsub(/\W/,'')
  end

  def remove_non_alphanumeric!
    self.gsub!(/\W/,'')
  end
end
