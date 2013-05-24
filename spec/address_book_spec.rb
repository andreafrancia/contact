require 'abook_import'

describe "address book" do
  subject { book }

  def backend() @backend ||= double 'backend' end
  def book()    @book    ||= Import.new backend end

  describe "input file" do

    it 'may contains multiple contacts' do
      given_input_file_is <<-EOF
      Marco Marchi 123
      Paolo Paoli   56
      EOF

      backend.should_receive(:person).with('Marco Marchi')
      backend.should_receive(:number).with('123')
      backend.should_receive(:person).with('Paolo Paoli')
      backend.should_receive(:number).with('56')

      book.main argf
    end

    it 'may contains email adresses' do 
      given_input_file_is 'Andrea Francia 555123 andrea@example.com'

      backend.should_receive(:person).with('Andrea Francia').ordered
      backend.stub(:number)
      backend.should_receive(:email).with('andrea@example.com').ordered

      book.main argf
    end

    describe 'a comment' do
      it 'starts with a pound sign' do     
        given_input_file_is '# this is a comment'

        book.main argf
      end
      it 'may happen in the middle of the line' do
        given_input_file_is '     # pound after some spaces'

        book.main argf
      end
    end
    describe 'empty line' do
      it 'is ignored' do
        given_input_file_is '     '

        book.main argf
      end
    end

    describe "name" do
      before :each do
        backend.stub(:number)
      end

      it 'appears before the number' do
        given_input_file_is 'Andrea Francia 021234'

        backend.should_receive(:person).with('Andrea Francia')

        book.main argf
      end

      it 'can be composed of three names' do
        given_input_file_is 'Andrea Gonzales Francia 0234'

        backend.should_receive(:person).with('Andrea Gonzales Francia')

        book.main argf
      end

    end

    describe 'numbers' do
      before :each do
        backend.stub(:person)
      end

      it 'can be just numbers' do
        given_input_file_is 'Andrea Francia 0601'

        backend.should_receive(:number).with('0601')

        book.main argf

      end

      it 'can start with a +' do
        given_input_file_is 'Andrea Francia +39123'

        backend.should_receive(:number).with('+39123')

        book.main argf
      end

      it 'can be more than one' do
        given_input_file_is 'Andrea Gonzales Francia 111 222 333'

        backend.should_receive(:number).with('111')
        backend.should_receive(:number).with('222')
        backend.should_receive(:number).with('333')

        book.main argf
      end
    end

    def argf
      return @argf
    end
  
    def given_input_file_is contents
      @argf = StringIO.new contents
    end
  end

end
