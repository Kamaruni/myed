def myed(commands)
  commands[1...-2].map { |line| line + "\n" }
end
RSpec.describe 'myed' do
  it 'inserting hello' do
    command = ["i", "hello", ".", ",p"]
    expect(myed(command)).to eq(call_ed(command))
  end
  it 'inserting codefreeze' do
    command = ["i", "codefreeze", ".", ",p"]
    expect(myed(command)).to eq(call_ed(command))
  end
  it 'inserting codefreeze twice on two lines' do
    command = ["i", "codefreeze", "codefreeze", ".", ",p"]
    expect(myed(command)).to eq(call_ed(command))
  end
end
def call_ed(commands)
  IO.popen('ed', 'r+') do |ed|
    ed.write(commands.join("\n") + "\nQ\n")
    ed.readlines
  end
end
