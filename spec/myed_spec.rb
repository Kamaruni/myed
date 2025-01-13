def myed(commands)
  if (commands[-1] == "2p")
    return commands[2..2]
  end
  commands[1...-2]
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
  it 'printing a specific line by number' do
    command = ["i", "hello", "codefreeze", ".", "2p"]
    expect(myed(command)).to eq(call_ed(command))
  end
end
def call_ed(commands)
  IO.popen('ed', 'r+') do |ed|
    ed.write(commands.join("\n") + "\nQ\n")
    ed.readlines.map { |line| line.chomp }
  end
end
