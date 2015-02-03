require_relative '../rails_helper'

RSpec::Matchers.define :eq_chunks do |expected|
  match do |actual|
    return false unless actual.size == expected.size

    (0...actual.size).each do |i|
      return false unless expected[i].lines.map(&:strip).join('') == actual[i].lines.map(&:strip).join('')
    end

    return true
  end
end

RSpec::Matchers.define :eq_template do |expected|
  match do |actual|
    expected.lines.map(&:strip).join('') == actual.lines.map(&:strip).join('')
  end
end

describe Techplater::Parser do
  let(:parser) { Techplater::Parser.new(text) }

  context "with verbatim items" do
    let(:text) { "<h1>h1</h1><p>p1</p><h2>h2</h2><p>p2</p>" }

    it "should have the correct chunks" do
      parser.parse!
      expect(parser.chunks).to eq_chunks([
        "<h1>h1</h1>",
        "<p>p1</p>",
        "<h2>h2</h2>",
        "<p>p2</p>"
      ])
    end

    it "should have the correct template" do
      parser.parse!
      expect(parser.template).to eq_template("{{{chunks.[0]}}}{{{chunks.[1]}}}{{{chunks.[2]}}}{{{chunks.[3]}}}")
    end
  end

  context "with invalid embedded img" do
    let(:text) { "<p><img src='blahblahblah'></p>" }

    it "should not include the image" do
      parser.parse!
      expect(parser.template).to eq_template("")
    end
  end

  context "with valid embedded img" do
    let(:text) { "<p><img src='http://localhost:3000/images/37/pictures/23/direct'></p>" }

    it "should have the correct chunks" do
      parser.parse!
      expect(parser.chunks).to eq_chunks([])
    end

    it "should have the correct template" do
      parser.parse!
      expect(parser.template).to eq_template('{{{imageTag 23 "default"}}}')
    end

    context "with floating left style" do
      let(:text) { "<p><img src='http://localhost:3000/images/37/pictures/23/direct' style='float: left; '></p>" }

      it "should have the correct chunks" do
        parser.parse!
        expect(parser.chunks).to eq_chunks([])
      end

      it "should have the correct template" do
        parser.parse!
        expect(parser.template).to eq_template('{{{imageTag 23 "left"}}}')
      end
    end
  end

  context "with empty paragraphs" do
    let(:text) { "<p>a</p><p></p>" }

    it "should remove the empty paragraphs" do
      parser.parse!
      expect(parser.chunks).to eq_chunks(["<p>a</p>"])
    end
  end

  context "with embedded h2" do
    let(:text) { "<div><p><h2>Header</h2></p></div>" }

    it "should have the correct chunks" do
      parser.parse!
      expect(parser.chunks).to eq_chunks(["<h2>Header</h2>"])
    end

    it "should have the correct template" do
      parser.parse!
      expect(parser.template).to eq_template("{{{chunks.[0]}}}")
    end
  end

  context "with embedded table" do
    let(:text) { "<div><p><table><thead><tr><th></th></tr></thead><tbody><tr><td></td></tr></tbody></table></p></div>" }

    it "should have the correct chunks" do
      parser.parse!
      expect(parser.chunks).to eq_chunks(["<table><thead><tr><th></th></tr></thead><tbody><tr><td></td></tr></tbody></table>"])
    end

    it "should have the correct template" do
      parser.parse!
      expect(parser.template).to eq_template("{{{chunks.[0]}}}")
    end
  end

  context "with further embedded table" do
    let(:text) { "<div><article><p><table><thead><tr><th></th></tr></thead><tbody><tr><td></td></tr></tbody></table></p></article></div>" }

    it "should have the correct chunks" do
      parser.parse!
      expect(parser.chunks).to eq_chunks(["<table><thead><tr><th></th></tr></thead><tbody><tr><td></td></tr></tbody></table>"])
    end

    it "should have the correct template" do
      parser.parse!
      expect(parser.template).to eq_template("{{{chunks.[0]}}}")
    end
  end

  context "with embedded blockquote" do
    let(:text) { "<div><p><blockquote><p>Something interesting. </p></blockquote></div>" }

    it "should have the correct chunks" do
      parser.parse!
      expect(parser.chunks).to eq_chunks(["<blockquote><p>Something interesting. </p></blockquote>"])
    end

    it "should have the correct template" do
      parser.parse!
      expect(parser.template).to eq_template("{{{chunks.[0]}}}")
    end
  end

  context "with legacy sub_head" do
    let(:text) { '<div class="bodysub" id="How_priorities_are_set"><p>How priorities are set </p></div>' }

    it "should convert it to h3 in chunks" do
      parser.parse!
      expect(parser.chunks).to eq_chunks(["<h3>How priorities are set </h3>"])
    end

    it "should include the chunk in the template" do
      parser.parse!
      expect(parser.template).to eq_template('{{{chunks.[0]}}}')
    end
  end

  context "with article lists" do
    let(:text) { "<ol data-article-list-id=\"13\" data-role=\"asset-article-list\"><li></li></ol>" }

    it "should parse the chunks correctly" do
      parser.parse!
      expect(parser.chunks).to eq_chunks([])
    end

    it "should include the article list in the template" do
      parser.parse!
      expect(parser.template).to eq_template('{{{articleListTag 13}}}')
    end
  end
end
