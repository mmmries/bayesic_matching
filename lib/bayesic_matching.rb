require "bayesic_matching/version"
require "bayesic_matching/matcher"
require "set"

class BayesicMatching
  def initialize
    @classifications = ::Set.new
    @classifications_by_token = {}
  end

  def finalize(opts = {})
    pruning_percent = opts.fetch(:pruning_percent, 0.5)
    threshold = @classifications.size * pruning_percent
    by_token = @classifications_by_token.each_with_object({}) do |(token, classifications), hash|
      class_count = classifications.size
      next if class_count > threshold
      hash[token] = {count: class_count, classifications: classifications}
    end
    BayesicMatching::Matcher.new(class_count: @classifications.size, by_token: by_token)
  end

  def train(tokens, classification)
    @classifications << classification
    tokens.each do |token|
      @classifications_by_token[token] ||= ::Set.new
      @classifications_by_token[token] << classification
    end
  end
end
