def myed(commands)
  [commands[1] + "\n"]
end
RSpec.describe 'myed' do
  it 'something' do
    expect(false).to eq(false)
  end
  it 'calling ed from ruby' do
    expect(call_ed(["i", "hello", ".", ",p"])).to eq(["hello\n"])
  end
  it 'inserting hello' do
    command = ["i", "hello", ".", ",p"]
    expect(myed(command)).to eq(call_ed(command))
  end
  it 'inserting codefreeze' do
    command = ["i", "codefreeze", ".", ",p"]
    expect(myed(command)).to eq(call_ed(command))
  end
end
def call_ed(commands)
  IO.popen('ed', 'r+') do |ed|
    ed.write(commands.join("\n") + "\nQ\n")
    ed.readlines
  end
end
