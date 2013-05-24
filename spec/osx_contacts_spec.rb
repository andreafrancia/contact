require 'osx_contacts'

framework 'addressbook'

describe 'OsxContacts' do

  before :all do
    contacts = OsxContacts.new
    book = ABAddressBook.sharedAddressBook

    contacts.remove_person "Ciccio Pasticcio"
    contacts.remove_person "Ciccio Boo"

    first_name = 'Ciccio'
    last_name = 'Pasticcio'

    person = contacts.create_person first_name, last_name 

    phone_numbers = ABMutableMultiValue.alloc.init
    phone_numbers.addValue '11', withLabel:KABPhoneMainLabel
    phone_numbers.addValue '22', withLabel:KABPhoneWorkLabel

    person.setValue phone_numbers, forProperty:KABPhoneProperty 

    book.addRecord person
    book.save
  end


  it 'should read phone numbers' do
    numbers = contacts.numbers_of "Ciccio Pasticcio"
    numbers.should == ['11', '22']
  end

  it 'should add phone numbers' do
    contacts.add_number_to "Ciccio Pasticcio", "33"
    numbers = contacts.numbers_of "Ciccio Pasticcio"
    numbers.should == ['11','22','33']
  end

  it 'should not add an already present number' do
    contacts.add_number_to "Ciccio Pasticcio", "11"
    numbers = contacts.numbers_of "Ciccio Pasticcio"
    numbers.should == ['11','22','33']
  end

  it 'should automatically add non present person' do
    contacts.add_number_to "Ciccio Boo", "3"

    numbers = contacts.numbers_of "Ciccio Boo"
    numbers.should == ['3']
  end

  def contacts
    @contacts ||= OsxContacts.new
  end
end
