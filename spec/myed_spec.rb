RSpec.describe 'myed' do
  it 'something' do
    expect(false).to eq(false)
  end
  it 'calling ed from ruby' do
    expect(call_ed(["i", "hello", ".", ",p"])).to eq(["hello\n"])
  end
end
def call_ed(commands)
  IO.popen('ed', 'r+') do |ed|
    ed.write(commands.join("\n") + "\nQ\n")
    ed.readlines
  end
end
