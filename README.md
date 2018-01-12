# BayesicMatching

Like NaiveBayes, except useful for the case of many possible classes with small training sets per class.

This is useful if you have two lists of names or titles and you want to match between them with a given confidence level.

## Usage

```ruby
trainer = BayesicMatching.new
trainer.train(["it","was","the","best","of","times"], "novel")
trainer.train(["tonight","on","the","seven","o'clock"], "news")
matcher = trainer.finalize

matcher.classify(["the","best","of"])
# => {"novel"=>1.0, "news"=>0.667}
matcher.classify(["the","time"])
#  => {"novel"=>0.667, "news"=>0.667}
```

## Pruning

One of the fastest ways to improve the speed of matching is to prune common tokens.
For example, if the token "the" is present in every single classification, then its presence doesn't tell you much about your confidence of a match, but we `BayesicMatching` would now return a confidence for every possible classification.
To avoid this there is a default pruning where any token that exists in more than 50% of your classifications will get pruned during the `finalize` call.
You can tune this pruning by passing `.finalize(pruning_percent: 0.25)`.
In my own usage I've found that pruning tokens that exist in more than `0.2` of all classifications has almost no impact on accuracy, but gives me a significant speed boost.

## How It Works

This library uses the basic idea of [Bayes Theorem](https://en.wikipedia.org/wiki/Bayes%27_theorem).

It records which tokens it has seen for each possible classification. Later when you pass a set of tokens and ask for the most likely classification it looks for all potential matches and then ranks them by considering the probabily of any given match according to the tokens that it sees.

Tokens which exist in many records (ie not very unique) have a smaller impact on the probability of a match and more unique tokens have a larger impact.

## Will It Work For My Dataset?

I'm using this in a project that has to match several hundred records against a list of ~10k possible matches.
At these sizes this project will train a matcher in ~10ms and each record that I check for a match takes ~1.2ms.

You can try it out with your own dataset by producing two simple CSV files and running the `examples/benchmark.rb` script in this repo.
For example you can run `bundle exec ruby benchmark.rb popular_recent_movies.csv favorite_recent_movies.csv` (those two files are provided in the examples directory as well).
If you can create a similar pair of CSV files you can test on whatever dataset you want and see the accuracy and performance of the library.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
