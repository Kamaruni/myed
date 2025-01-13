RSpec.describe 'myed' do
  it 'something' do
    expect(false).to eq(false)
  end
  it 'calling ed from ruby' do
    expect(call_ed(["i", "hello", ".", ",p"])).to eq("hello\n")
  end
end
def call_ed(commands)
  ed = IO.popen('ed', 'r+')
  ed.write(commands.join("\n") + "\n")
  ed.gets
end
