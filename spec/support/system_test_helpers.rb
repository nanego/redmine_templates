module SystemTestHelpers
  def pause_test(message = "Pause test")
    puts "\n" + "=" * 50
    puts "️=>  #{message}"
    puts "=" * 50
    puts "URL: #{current_url}"
    puts "\nAppuyez sur Entrée pour continuer le test..."
    $stdin.gets
    puts "=>  Reprise du test..."
  end
end

RSpec.configure do |config|
  config.include SystemTestHelpers, type: :system
end
