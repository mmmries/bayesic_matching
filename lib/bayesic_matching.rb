require "bayesic_matching/version"
require "set"

class BayesicMatching
  def initialize
    @classifications = ::Set.new
    @classifications_by_token = {}
    @tokens_by_classification = {}
  end

  def classify(tokens)
    tokens = tokens.reject{|t| @classifications_by_token[t].nil? }.uniq
    tokens.each_with_object({}) do |token, hash|
      @classifications_by_token[token].each do |c|
        p_klass = hash[c] || (1.0 / @classifications.size)
        p_not_klass = 1.0 - p_klass
        p_token_given_klass = 1.0
        p_token_given_not_klass = (@classifications_by_token[token].size - 1) / @classifications.size.to_f
        hash[c] = (p_token_given_klass * p_klass) / ((p_token_given_klass * p_klass) + (p_token_given_not_klass * p_not_klass))
      end
    end
  end

  def train(tokens, classification)
    @classifications << classification
    @tokens_by_classification[classification] ||= ::Set.new
    tokens.each do |token|
      @tokens_by_classification[classification] << token
      @classifications_by_token[token] ||= ::Set.new
      @classifications_by_token[token] << classification
    end
  end
end
