RSpec.describe BayesicMatching do
  before do
    subject.train(["once","upon","a","time"], "story")
    subject.train(["tonight","on","the","news"], "news")
    subject.train(["it","was","the","best","of","times"], "novel")
  end

  it "can classify matching tokens" do
    matcher = subject.finalize
    classification = matcher.classify(["once","upon","a","time"])
    expect(classification.keys).to include("story")
    expect(classification["story"]).to be >= 0.9
  end

  it "can classify not exact matches" do
    matcher = subject.finalize
    classification = matcher.classify(["the","time"])
    expect(classification.keys).to include("story")
    expect(classification["story"]).to be >= 0.9
  end

  it "returns no potential matches for nonsense" do
    matcher = subject.finalize
    expect(matcher.classify(["ferby"])).to eq({})
  end
end
