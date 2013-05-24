class Import 
  def initialize backend
    @backend = backend
  end
  def main argf
    contents = argf.read
    contents.each_line do | line|
      line = line[/^[^#]*/]

      line.strip!
      if not line == ''
        tokens = line.split ' '
        names = []
        numbers = []
        emails = []
        tokens.each do |token|
          token.strip!
          if token =~ /@/
            emails.push token
          elsif token =~ /^\+?[[:digit:]]+$/
            numbers.push token
          else 
            names.push token
          end
        end
        name = names.join ' '
        @backend.person name
        numbers.each { |number| @backend.number number }
        emails.each { |email| @backend.email email }
      end
    end
  end
end

class FileSystem
  def read filename
    return File.read(filename)
  end
end

class PrintPerson
  def person name
    puts name
  end
  def number number
    puts "\t#{number}"
  end
  def email email
    puts "\t#{email}"
  end
end

