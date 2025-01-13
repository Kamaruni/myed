RSpec.describe 'myed' do
  it 'something' do
    expect(false).to eq(false)
  end
  it 'calling ed from ruby' do
    ed = IO.popen('ed', 'r+')
    ed.write("i\nhello\n.\n,p\n")
    expect(ed.gets).to eq("hello\n")
  end
end
