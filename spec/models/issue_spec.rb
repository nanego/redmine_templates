require "spec_helper"

describe "Issue" do

  fixtures :issues

  let!(:issue) { Issue.find(1) }

  describe :generated_subject_from_pattern do

    it "returns the current pattern if pattern does not include variables" do
      pattern = "Cannot add articles to shopping cart"
      expect(issue.generated_subject(pattern: pattern)).to eq pattern
    end

    describe :issue_attributes do
      it "replaces tracker variable with current issue tracker" do
        pattern = "{tracker}: Cannot add articles to shopping cart"
        expect(issue.generated_subject(pattern: pattern)).to eq "Bug: Cannot add articles to shopping cart"
      end

      it "replaces priority variable with current issue priority" do
        pattern = "Cannot add articles to shopping cart ({priority})"
        expect(issue.generated_subject(pattern: pattern)).to eq "Cannot add articles to shopping cart (Low)"
      end

      it "can replace multiple variables" do
        pattern = "{tracker}: Cannot add articles to shopping cart ({priority})"
        expect(issue.generated_subject(pattern: pattern)).to eq "Bug: Cannot add articles to shopping cart (Low)"
      end

      it "can include version and project" do
        pattern = "{tracker} {project} → {fixed_version}"
        issue.fixed_version_id = 3
        expect(issue.generated_subject(pattern: pattern)).to eq "Bug eCookbook → 2.0"
      end
    end

    describe :custom_fields do

      it "replaces custom_field variable with current value when using cf id" do
        pattern = "{cf_2}: Cannot add articles to shopping cart"
        expect(issue.generated_subject(pattern: pattern)).to eq "125: Cannot add articles to shopping cart"
      end

      it "replaces custom_field variable with current value when using cf name" do
        pattern = "{cf_searchable_field}: Cannot add articles to shopping cart"
        expect(issue.generated_subject(pattern: pattern)).to eq "125: Cannot add articles to shopping cart"
      end

    end

  end

end
