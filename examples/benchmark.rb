require "bayesic_matching"
require "benchmark/ips"
require "csv"

if ARGV.size < 2
  puts "please provide a pair of CSV files. (i.e. ruby benchmark.rb training.csv matching.csv)"
  puts "\ttraining.csv should have source_id and source_string columns"
  puts "\tmatching.csv should have match_string and source_id columns"
  exit(1)
end

training_csv_path = ARGV[0]
matching_csv_path = ARGV[1]

# You can tokenize your strings using many different schemes. Below are two common defaults you might want to choose.
# you can change this to do trigrams or something else
# this default implementation creates a list of downcased words
# with punctuation stripped off
# and removes words less than 2 characters long
 def tokenize_string(str)
   str.downcase.split(/\b+/).map do |word|
     word.gsub(/[^\w ]/,"")
   end.reject{|word| word.size < 2 }
 end
 # a version which glues all of the downcased words together and
 # splits them into trigrams
#def tokenize_string(str)
#  str.downcase.gsub(/[^\w]/,"").chars.each_cons(3).to_a.map{|trigram| trigram.join("") }
#end

training_rows = []
::CSV.foreach(training_csv_path, :headers => true, :header_converters => :symbol) do |row|
  training_rows << {:string => row[:source_string], :id => row[:source_id], :tokens => tokenize_string(row[:source_string])}
end

matching_rows = []
::CSV.foreach(matching_csv_path, :headers => true, :header_converters => :symbol) do |row|
  matching_rows << {:string => row[:match_string], :source_id => row[:source_id], :tokens => tokenize_string(row[:match_string])}
end

def train_matcher(training_rows)
  matcher = BayesicMatching.new
  training_rows.each do |row|
    matcher.train(row[:tokens], row[:id])
  end
  matcher
end

def attempt_matches(matcher, matching_rows, print_mismatch_data = false)
  results = {:correct => 0, :incorrect => 0, :unmatched => 0, :total => 0}
  matching_rows.each do |row|
    probabilities = matcher.classify(row[:tokens])
    next if row[:source_id].nil? or row[:source_id].size == 0 # if no source_id was present don't bother counting the statistics
    results[:total] += 1
    if probabilities.empty?
      results[:unmatched] += 1
    else
      best_match, confidence = probabilities.max_by{|_klass, probability| probability }
      if best_match == row[:source_id]
        results[:correct] += 1
      else
        results[:incorrect] += 1
        if print_mismatch_data
          puts "MISMATCH of #{row[:string]} (#{row[:tokens]}) to #{best_match} (should have been #{row[:source_id]})"
          puts "\tconfidence: #{probabilities[best_match]}"
        end
      end
    end
  end
  results
end

matcher = train_matcher(training_rows)

Benchmark.ips do |x|
  x.config(:time => 5, :warmup => 2)
  x.report("training") { train_matcher(training_rows) }
  x.report("matching") { attempt_matches(matcher, matching_rows) }
end

puts "= Checking Accuracy"
results = attempt_matches(matcher, matching_rows, true)

puts "= Accuracy Results"
puts "\t#{results[:total]} attempted matches"
puts "\t#{results[:correct]} correct (#{results[:correct].to_f / results[:total]}%)"
puts "\t#{results[:incorrect]} incorrect (#{results[:incorrect].to_f / results[:total]}%)"
puts "\t#{results[:unmatched]} unmatched (#{results[:unmatched].to_f / results[:total]}%)"
