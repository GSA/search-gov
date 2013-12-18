module NumbersHelper
  def non_zero_number_with_delimiter(number, zero_label = 'n/a')
    number.zero? ? zero_label : number_with_delimiter(number)
  end
end
