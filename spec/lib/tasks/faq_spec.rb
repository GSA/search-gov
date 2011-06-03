require 'spec/spec_helper'

describe "faq rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/faq"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:faq" do

    describe "usasearch:faq:load" do
      before do
        @task_name = "usasearch:faq:load"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given an xml file" do
        it "should print out an error message" do
          Rails.logger.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given an xml file" do
        before do
          @tmp_dir = ::Rails.root.join('tmp', 'test')
          Dir.mkdir(@tmp_dir) unless File.exists?(@tmp_dir)
          @tmp_faq = <<'EOF'
          <?xml version="1.0" encoding="utf-8"?>
          <Report>
          <Field>XML Content Feed</Field>
            <Row>
              <Item>Link to Content</Item>
              <Item>Question</Item>
              <Item>Answer</Item>
              <Item>Aproximate Ranking</Item>
            </Row>
            <Row>
              <Item>http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/std_adp.php?p_faqid=32</Item>
              <Item>&lt;p&gt;Authenticating Documents: Status Request&lt;/p&gt;</Item>
              <Item>&lt;p&gt;The authentication of documents by the &lt;rn:answer_xref answer_id="203" contents="Office of Authentications" /&gt;&amp;nbsp;at the &lt;rn:answer_xref answer_id="4391" contents="United States Department of State (DOS)" /&gt;&amp;nbsp;takes approximately&amp;nbsp;five busines</Item>
              <Item>3248</Item>
            </Row>
          </Report>
EOF
          @xml_file_name = "faqs.xml"
          File.open("#{@tmp_dir}/#{@xml_file_name}", "w+") {|f| f.write(@tmp_faq) }
          File.open("#{@tmp_dir}/b", "w+") {|f| f.write(@tmp_faq) }
        end

        context "when no locale is specified" do
          it "should delete all the existing faqs in the table for the default locale" do
            Faq.should_receive(:delete_all).with(['locale=?', I18n.default_locale.to_s])
            @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}")
          end

          it "should assign the proper values to the proper fields, including stripping HTML from the question field, for the default locale" do
            Faq.should_receive(:create).with(:url => 'http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/std_adp.php?p_faqid=32',
                                             :question => 'Authenticating Documents: Status Request',
                                             :answer => '<p>The authentication of documents by the <rn:answer_xref answer_id="203" contents="Office of Authentications" />&nbsp;at the <rn:answer_xref answer_id="4391" contents="United States Department of State (DOS)" />&nbsp;takes approximately&nbsp;five busines',
                                             :ranking => 3248,
                                             :locale => I18n.default_locale.to_s)
            @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}")
          end
        end

        context "when a locale is specified" do
          before do
            @locale = 'es'
          end

          it "should delete all the existing faqs in the table" do
            Faq.should_receive(:delete_all).with(['locale=?', @locale])
            @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}", @locale)
          end

          it "should assign the proper values to the proper fields, including stripping HTML from the question field" do
            Faq.should_receive(:create).with( :url => 'http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/std_adp.php?p_faqid=32',
                                              :question => 'Authenticating Documents: Status Request',
                                              :answer => '<p>The authentication of documents by the <rn:answer_xref answer_id="203" contents="Office of Authentications" />&nbsp;at the <rn:answer_xref answer_id="4391" contents="United States Department of State (DOS)" />&nbsp;takes approximately&nbsp;five busines',
                                              :ranking => 3248,
                                              :locale => @locale)
            @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}", @locale)
          end
        end

        it "should create a Faq entry for each 'Row' in the file, except the first line" do
          Faq.should_receive(:create).exactly(1).times
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}")
        end

        it "should skip the first line" do
          Faq.should_not_receive(:create).with(:url => 'Link to Content',
                                               :question => 'Question',
                                               :answer => 'Answer',
                                               :ranking => 'Approximate Ranking',
                                               :locale => I18n.default_locale.to_s)
          @rake[@task_name].invoke("#{@tmp_dir}/#{@xml_file_name}")
        end

        after do
          FileUtils.rm_r(@tmp_dir)
        end

      end

    end


    describe "usasearch:faq:grab_and_load" do


      before do
        @task_name = "usasearch:faq:grab_and_load"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when given an sftp config entry" do
        before do
          @tmp_dir = ::Rails.root.join('tmp', 'faq')
          @config_file = ::Rails.root.join('tmp', 'faq')
        end

        it "should not do anything if the grab returns nil" do
          Faq.stub!(:grab_latest_file).and_return nil
          Faq.should_receive(:grab_latest_file).with("en")
          @rake[@task_name].should_not_receive(:load_faqs_from_file)
          @rake[@task_name].invoke
        end
      end
    end

    describe "usasearch:faq:clean" do
      before do
        Faq.create!(:url =>  "http://www.usa.gov",
                    :question => "What is the url of USA.gov?",
                    :answer => 'The URL for USA.gov is http://www.usa.gov',
                    :ranking => 100)
        @task_name = "usasearch:faq:clean"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should remove all clicks from database" do
        Faq.count.should > 0
        @rake[@task_name].invoke
        Faq.count.should be_zero
      end
    end

  end

end
