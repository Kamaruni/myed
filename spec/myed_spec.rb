RSpec.describe 'myed' do
  it 'something' do
    expect(false).to eq(false)
  end
  it 'calling ed from ruby' do
    IO.popen('ed', 'r+') do |ed|
    ed.write("i\nhello\n.\n,p\nq\n")
    expect(ed.gets).to eq("hello\n")
    end
  end
end
