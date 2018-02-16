shared_examples 'a non-prod git info banner' do
  describe 'sites/shared/_header' do
    describe 'git info non-prod system name header' do
      let(:system_name) { 'Specville' }
      let(:show_header) { false }

      def current_user
        :available
      end

      before do
        @original_system_name = $git_info.system_name
        @original_show_header = $git_info.show_header
        $git_info.system_name = system_name
        $git_info.show_header = show_header

        render
      end

      after do
        $git_info.system_name = @original_system_name
        $git_info.show_header = @original_show_header
      end

      context 'when there is no system_name present' do
        it 'should not show a warning banner' do
          expect(rendered).not_to have_selector('system-warning')
        end
      end

      context 'when there is a system_name present' do
        let(:show_header) { true }

        it 'should show a warning banner indicating non-production environment' do
          expect(rendered).to have_selector('.system-warning', text: "You are viewing a non-production version of Search.gov on #{system_name}")
        end
      end
    end
  end
end
