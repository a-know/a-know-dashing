class FizzBuzz
  FIZZ=3
  BUZZ=5

  def initialize
    @current_num = 1
  end

  def fizzbuzz
    if fizzbuzz?
      out = "fizzbuzz"
    elsif fizz?
      out = "fizz"
    elsif buzz?
      out = "buzz"
    else
      out = @current_num
    end
    go_next
    out
  end

  private

  def go_next
    @current_num+=1
  end

  def fizz?
    (@current_num % 3) == 0
  end

  def buzz?
    (@current_num % 5) == 0
  end

  def fizzbuzz?
    (@current_num % (FIZZ*BUZZ)) == 0
  end

end

fb = FizzBuzz.new

SCHEDULER.every '5s', :first_in => 0 do
  send_event('fizz_buzz', { value: fb.fizzbuzz })
end