# frozen_string_literal: true

module SystemHelpers
  def sign_in(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: user.password
    click_button "Enter"
    expect(page).to have_content "Successfully logged in. Enjoy your stay!"
  end

  def slim_select(option, from:)
    # Avoid removing selected options from multi selects by specifically
    # clicking the arrow inside the slim select box.
    find_all("div.ss-main.#{from}>.ss-arrow").first.click
    regex = /\A#{Regexp.escape(option)}\z/
    expect(page).to have_css "div.ss-option", text: regex
    find("div.ss-option", text: regex).click
  end

  def stub_live_search(query, record, *fields)
    collection = record.class.collection_name
    hit = record.slice(*fields).merge(
      "id" => record.id.to_s,
      "objectID" => "#{collection}/#{record.id}",
      "collection" => collection,
      "_rawTypesenseHit" => {"collection" => collection}
    )
    page.execute_script(<<~JS, "#{collection}:#{query}", hit)
      const config = document.getElementById('typesense-config');
      const hits = JSON.parse(config.dataset.testSearchHits ?? '{}');
      hits[arguments[0]] = [arguments[1]];
      config.dataset.testSearchHits = JSON.stringify(hits);
    JS
  end
end
