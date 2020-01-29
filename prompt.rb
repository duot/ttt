module Prompt
  def ask_int(msg, condition_proc)
    loop do
      print msg
      choice = gets.chomp.to_i
      break choice if condition_proc.call(choice)
    end
  end

  def ask_word(msg)
    loop do
      print msg
      choice = gets.chomp.strip
      break choice unless choice.empty?
    end
  end

  def ask_options(msg, options)
    loop do
      print msg
      input = gets.chomp.downcase
      break input if options.include? input
    end
  end
end
