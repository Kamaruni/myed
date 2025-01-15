require_relative './spec_helper'
class MyEd
  def initialize(buffer)
    @buffer = buffer
    @current_line = buffer.size - 1
  end
  def execute_command(current_command)
    if @mode == :insert
      execute_insert_mode_command(current_command)
    elsif current_command == "i"
      self.enter_insert_mode()
    elsif current_command.match? /^\d+$/
      self.jump_to_line(current_command)
    elsif current_command == "d"
      self.delete_line()
    else
      self.print_lines(current_command)
    end
  end
    def execute_insert_mode_command(command)
      if command == "."
        @mode = :command
        @buffer = @buffer[0...@current_line] + @insert_buffer + (@buffer[@current_line..-1] || [])
        @current_line = @insert_buffer.size - 1 if @current_line == -1
      else
        @insert_buffer.append(command)
      end
      []
    end
  def enter_insert_mode()
    @mode = :insert
    @insert_buffer = []
    []
  end
  def jump_to_line(command)
    line_number = command.to_i() - 1
    @current_line = line_number
    @buffer[line_number..line_number]
  end
  def delete_line()
    @buffer.delete_at(@current_line)
    @current_line = [@buffer.size - 1, @current_line].min
    []
  end
  def print_lines(command)
      @buffer[parse_address(command[0...-1], @current_line)]
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
