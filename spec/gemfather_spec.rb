require "fileutils"

RSpec.describe Gemfather::Cli::Runner do
  describe "run" do
    subject { described_class.new(settings_builder: settings_builder).call }

    let(:settings_builder) { instance_double("Gemfather::Cli::SettingsBuilder") }
    let(:settings_mock) do
      {
        name: "new_gem",
        summary: "new_summary",
        description: "new_description",
        homepage: "new_homepage",
        linter: "Rubocop",
        test: "RSpec",
        ci: "GitHub",
        makefile: true,
        coc: true,
        debugger: "IRB"
      }
    end
    before do
      allow(settings_builder).to receive(:call).and_return(settings_mock)
    end

    it "runs successfuly" do
      subject

      expect(File).to exist("new_gem")
    end

    after do
      FileUtils.remove_dir("new_gem")
    end
  end
end
