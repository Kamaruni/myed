require_relative './spec_helper'
class MyEd
  def initialize(buffer, filename = nil)
    @buffer = buffer
    @current_line = buffer.size - 1
    @filename = filename
  end
  def execute_command(current_command)
    if modifying?
      execute_modifying_command(current_command)
    elsif current_command == "i" || current_command == "c" || current_command == "a"
      enter_modifying_mode(current_command)
    elsif current_command.match? /^\d+$/
      self.jump_to_line(current_command)
    elsif current_command.end_with?("d")
      delete_line(current_command)
    elsif current_command == "w"
      write_file()
    else
      self.print_lines(current_command)
    end
  end
  def write_file()
    output = @buffer.join("\n")
    output += "\n" unless output.empty?
    [File.write(@filename, output).to_s]
  end
  def modifying?()
    @mode == :insert || @mode == :change || @mode == :append
  end
  def execute_modifying_command(command)
      if command == "."
    if @mode == :append
      @buffer = @buffer[0..@current_line] + @modifying_buffer + (@buffer[(@current_line + 1)..-1] || [])
      @mode = :command
      return []
    end
    if @mode == :change
      @buffer = @buffer[0...@current_line] + @modifying_buffer + (@buffer[(@current_line + 1)..-1] || [])
      @mode = :command
      return []
    end
      @mode = :command
        @buffer = @buffer[0...@current_line] + @modifying_buffer + (@buffer[@current_line..-1] || [])
        @current_line = @modifying_buffer.size - 1 if @current_line == -1
      else
        @modifying_buffer.append(command)
      end
      []
    end
  def enter_modifying_mode(command)
    @mode = case command[-1]
            when "i"
              :insert
            when "c"
              :change
            when "a"
              :append
            end
    @modifying_buffer = []
    []
  end
  def jump_to_line(command)
    line_number = command.to_i() - 1
    @current_line = line_number
    @buffer[line_number..line_number]
  end
  def delete_line(command)
    address = parse_address(command[0...-1], @current_line)
    @buffer = @buffer[0...address.first] + @buffer[(address.last + 1)..-1]
    @current_line = [@buffer.size - 1, @current_line].min
    []
  end
  def print_lines(command)
      address = parse_address(command[0...-1], @current_line)
      if command[-1] == "n"
        @buffer[address].each_with_index.map { |line, index| "#{index + address.first + 1}\t#{line}" }
      else
        @buffer[address]
      end
  end
end
def myed(commands)
  buffer = []
  myed = MyEd.new(buffer)
  commands.flat_map do |current_command|
    myed.execute_command(current_command)
  end
end
def parse_address(range, current_line)
  return 0..-1 if range == ","
  return (current_line..current_line) if range == ""
  address_start, address_end = range.split(",")
  address_start = [1, address_start.to_i].max
  address_end ||= address_start
  (address_start.to_i() -1)..(address_end.to_i() -1)
end
RSpec.describe 'myed' do
  it 'jumps to line 2' do
    verify(["i", "a", "b", ".", "2"])
  end
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
  it 'print unbounded end' do
    command = ["i", "1", "2", "3", "4", ".", "2,$p"]
    verify(command)
  end
  it 'print single line on no explicit end' do
    command = ["i", "1", "2", "3", "4", ".", "2,p"]
    verify(command)
  end
  it 'prints current line, 1 initially' do
    verify(["i", "a", ".", "p"])
  end
  it 'jumps to line 1' do
    verify(["i", "a", "b", ".", "1"])
  end
  it 'prints current line twice' do
    verify(["i", "hello", ".", "p", "p"])
  end
  it 'deletes the current line' do
    verify(["i", "one", "two", ".", "d", "p"])
  end
  it 'jumps to first line and deletes it' do
    verify(["i", "one", "two", ".", "1", "d", "1p"])
  end
  it 'writes in two separate insert sessions' do
    verify(["i", "one", ".", "i", "two", ".", ",p"])
  end
  it 'write in three separate insert sessions' do
    verify(["i", "one", ".", "i", "two", ".", "i", "three", ".", ",p"])
  end
  it 'inserts multiple lines in two separate insert sessions' do
    verify(["i", "1", "2", ".", "i", "3", "4", ".", ",p"])
  end
  it 'prints contents with line numbers' do
    verify(["i", "one", "two", "three", ".", "2,$n"])
  end
  it 'change first line' do
    verify(["i", "hello", "world", ".", "1", "c", "hi", ".", ",p"])
  end
  it 'changes the second line' do
    verify(["i", "hello", "world", ".", "c", "steve", ".", ",n"])
  end
  it 'changes two lines' do
    verify(["i", "hello", "world", "!", ".", "2", "c", "Steve", "Stevenson", ".", ",n"])
  end
  it 'deletes line when change is empty' do
    verify(["i", "one", "two", ".", "1", "c", ".", ",p"])
  end
  it 'appends a line to an empty document' do
    verify(["a", "hello", ".", ",p"])
  end
  it 'appends a line at the end' do
    verify(["i", "a", "b", ".", "a", "c", ".", ",p"])
  end
  it 'appends after the first of two lines' do
    verify(["i", "one", "two", ".", "1", "a", "one and a half", ".", ",p"])
  end
  it 'deletes two lines' do
    verify(["i", "one", "two", "three", ".", "1,2d", ",p"])
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
