class String

  unless method_defined?(:byteslice)
    def byteslice(*args)
      self.dup.force_encoding('ASCII-8BIT').slice!(*args)
    end
  end

  unless method_defined?(:force_encoding)
    def force_encoding(encoding)
      self # noop
    end
  end

end

