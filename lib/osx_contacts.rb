framework 'Foundation'
framework 'AddressBook'

class OsxContacts
  def add_number_to complete_name, number
    person = find_person_by_complete_name complete_name
    person = create_person complete_name, nil if not person
    
    if not person.numbers.include? number
      current_numbers = person.valueForProperty KABPhoneProperty
      if current_numbers 
        new_numbers = current_numbers.mutableCopy
      else
        new_numbers = ABMutableMultiValue.alloc.init
      end
      new_numbers.addValue number, withLabel:KABPhoneMainLabel

      person.setValue new_numbers, forProperty:KABPhoneProperty

      book.addRecord person
      book.save
    end
  end

  def create_person first_name, last_name
    person = ABPerson.new
    person.setValue first_name, forProperty: KABFirstNameProperty
    person.setValue last_name, forProperty: KABLastNameProperty
    book.addRecord person
    book.save
    return person
  end

  def numbers_of complete_name
    person = find_person_by_complete_name complete_name
    return person.numbers
  end

  def remove_person complete_name
    people_with_complete_name(complete_name).each do | person|
      book.removeRecord person
    end
    book.save
  end

  private 

  def book
    ABAddressBook.sharedAddressBook
  end
  
  def people_with_complete_name complete_name
    matching = []
    everyone.each do |person|
      matching << person if complete_name == person.complete_name
    end
    return matching
  end
  def find_person_by_complete_name complete_name
    people = people_with_complete_name complete_name
    people.first
  end
  def everyone
    book.people
  end
end

class ABPerson
  def complete_name
    components = []
    [KABFirstNameProperty, 
     KABLastNameProperty,
     KABOrganizationProperty].each do |label|
      value = self.valueForProperty label
      components.push value if value
    end
    return components.join ' '
  end
  def numbers
    numbers = []
    phones = self.valueForProperty KABPhoneProperty
    if phones
      (0...phones.count).each do |index|
          value = phones.valueAtIndex index
          numbers << value
      end
    end
    numbers
  end
  
end

class SavePerson
  def initialize
    @book = OsxContacts.new
  end
  def person name
    @name = name
  end
  def number number
    @book.add_number_to @name, number
  end
  def email email
    puts "Sorry not setting email '#{email}' for #{@name}"
  end
end
