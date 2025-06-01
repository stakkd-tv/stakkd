RSpec.shared_examples_for "a slugified model" do |model, slug_source|
  describe "before_validation #slugify" do
    context "when a slug is already provided" do
      it "does not update the slug" do
        attrs = {}
        attrs[slug_source] = "Back to the Future"
        record = FactoryBot.build(model, slug: "amazing-name", **attrs)
        record.save!
        expect(record.reload.slug).to eq "amazing-name-#{record.id}"
      end
    end

    context "when a slug is not provided" do
      it "updates the slug" do
        attrs = {}
        attrs[slug_source] = "Back to the Future"
        record = FactoryBot.build(model, slug: nil, **attrs)
        record.save!
        expect(record.reload.slug).to eq "back-to-the-future-#{record.id}"
      end
    end

    context "when slug source is nil" do
      it "does not raise an error, and sets valid to false" do
        attrs = {}
        attrs[slug_source] = nil
        record = FactoryBot.build(model, slug: nil, **attrs)
        record.save
        expect(record.valid?).to be_falsey
      end
    end

    context "when slug source contains a non-alphanumeric character" do
      it "removes the non-alphanumeric characters and updates the slug" do
        attrs = {}
        attrs[slug_source] = "#Back & to the Future!"
        record = FactoryBot.build(model, slug: nil, **attrs)
        record.save
        expect(record.reload.slug).to eq "back-to-the-future-#{record.id}"
      end
    end
  end

  describe ".from_slug" do
    context "when an id is specified" do
      it "returns the record with the id" do
        record = FactoryBot.create(model)
        klass = record.class
        slug = "sluggg-#{record.id}"
        expect(klass.from_slug(slug)).to eq record
      end
    end

    context "when an id is not specified" do
      it "raises an error" do
        klass = FactoryBot.build(model).class
        slug = "sluggg-some-bogus-thing"
        expect { klass.from_slug(slug) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
