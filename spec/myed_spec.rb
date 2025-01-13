def myed(commands)
  if (commands[-1] == ",p")
    return commands[1...-2]
  end
  commands[parse_address(commands[-1][0...-1])]
end
def parse_address(range)
  address_start, address_end = range.split(",")
  address_start = [1, address_start.to_i].max
  address_end ||= address_start
  (address_start.to_i)..(address_end.to_i)
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
  it 'prints line 10' do
    command = ["i", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", ".", "10p"]
    verify(command)
  end
  it 'print bounded range of lines' do
    command = ["i", "1", "2", "3", "4", ".", "2,3p"]
    verify(command)
  end
  it 'print range with unbounded start' do
    command = ["i", "1", "2", "3", "4", ".", ",3p"]
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
