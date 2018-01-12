class BayesicMatching
  class Matcher
    def initialize(class_count:, by_token:)
      @class_count = class_count
      @by_token = by_token
      @prior = 1.0 / class_count
    end

    def classify(tokens)
      tokens = tokens.reject{|t| !@by_token.has_key?(t) }.uniq
      tokens.each_with_object({}) do |token, hash|
        @by_token[token][:classifications].each do |c|
          p_klass = hash[c] || @prior
          p_not_klass = 1.0 - p_klass
          p_token_given_klass = 1.0
          p_token_given_not_klass = (@by_token[token][:count] - 1) / @class_count.to_f
          hash[c] = (p_token_given_klass * p_klass) / ((p_token_given_klass * p_klass) + (p_token_given_not_klass * p_not_klass))
        end
      end
    end
  end
end
