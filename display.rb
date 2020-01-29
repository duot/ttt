module Display
  def clear
    system('clear') || system('cls')
  end
end
