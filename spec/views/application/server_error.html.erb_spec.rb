require "rails_helper"

RSpec.describe "application/server_error", type: :view do
  before(:each) do
    allow(Rails).to receive(:root).and_return("/path/to/rails/root")
    error = instance_double(
      StandardError,
      backtrace: [
        "/path/to/rails/root/and/some/error/file.rb",
        "/some/gems/version/gems/path/to/error/file.rb"
      ],
      message: "Some error message"
    )
    allow(request).to receive(:path).and_return("/path/to/error")
    assign(:error, error)
  end

  it "renders some information of the error" do
    render
    expect(rendered).to include("Error: RSpec::Mocks::InstanceVerifyingDouble")
    expect(rendered).to include("Message: Some error message")
    expect(rendered).to include("Request path: /path/to/error")
    expect(rendered).to include("[APP]/and/some/error/file.rb")
    expect(rendered).to include("[GEMS]/path/to/error/file.rb")
    expect(rendered).not_to include("/path/to/rails/root/and/some/error/file.rb")
    expect(rendered).not_to include("/some/gems/version/gems/path/to/error/file.rb")
  end
end
