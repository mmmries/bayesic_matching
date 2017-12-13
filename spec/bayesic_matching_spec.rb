RSpec.describe BayesicMatching do
  before do
    subject.train(["once","upon","a","time"], "story")
    subject.train(["tonight","on","the","news"], "news")
    subject.train(["it","was","the","best","of","times"], "novel")
  end

  it "can classify matching tokens" do
    classification = subject.classify(["once","upon","a","time"])
    expect(classification.keys).to include("story")
    expect(classification["story"]).to be >= 0.9
  end

  it "can classify not exact matches" do
    classification = subject.classify(["the","time"])
    expect(classification.keys).to include("story")
    expect(classification["story"]).to be >= 0.9
  end

  it "returns no potential matches for nonsense" do
    expect(subject.classify(["ferby"])).to eq({})
  end
end
