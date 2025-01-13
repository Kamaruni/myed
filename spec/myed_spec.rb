def myed(commands)
  if (commands[-1] == ",p")
    return commands[1...-2]
  end
  line_no = commands[-1][0...-1].to_i
  commands[line_no..line_no]
end
RSpec.describe 'myed' do
  it 'inserting hello' do
    command = ["i", "hello", ".", ",p"]
    verify(command)
  end
  it 'inserting codefreeze' do
    command = ["i", "codefreeze", ".", ",p"]
    verify(command)
  end
  it 'inserting codefreeze twice on two lines' do
    command = ["i", "codefreeze", "codefreeze", ".", ",p"]
    verify(command)
  end
  it 'printing a specific line by number' do
    command = ["i", "hello", "codefreeze", ".", "2p"]
    verify(command)
  end
  it 'printing the first line' do
    command = ["i", "hello", "codefreeze", ".", "1p"]
    verify(command)
  end
end
def verify(commands)
  expect(myed(commands)).to eq(call_ed(commands))
end
def call_ed(commands)
  IO.popen('ed', 'r+') do |ed|
    ed.write(commands.join("\n") + "\nQ\n")
    ed.readlines.map { |line| line.chomp }
  end
end
