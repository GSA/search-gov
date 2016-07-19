require 'spec_helper'

describe 'migrate images' do
  fixtures(:featured_collections)
  fixtures(:affiliates)

  before(:all) do
    Rake.application.rake_require('tasks/image_migrator')
    Rake::Task.define_task(:environment)
  end

  before { Rake::Task['usasearch:migrate_images'].reenable }

  describe 'usasearch:migrate_images' do
    let(:image) { File.open(Rails.root.join('spec/fixtures/images/corgi.jpg')) }

    it "should have 'environment' as a prereq" do
      Rake::Task['usasearch:migrate_images'].prerequisites.should include("environment")
    end

    context 'copying affiliate images' do
      let!(:affiliate) do
        affiliate = affiliates(:usagov_affiliate)
        affiliate.update_attributes!(header_image: image,
                                    header_tagline_logo: image,
                                    page_background_image: image,
                                    mobile_logo: image)

        affiliate
      end

      subject(:migrate_affiliate_images) do
        Rake::Task['usasearch:migrate_images'].invoke('affiliates')
      end

      context 'when the migration succeeds' do
        before do
          migrate_affiliate_images
          affiliate.reload
        end

        it 'saves a copy of the image to AWS' do
          %i{ aws_header_image
              aws_header_tagline_logo
              aws_page_background_image
              aws_mobile_logo
            }.each do |image|
              expect(affiliate.send(image).url).to match /s3\.amazonaws\.com/
          end
        end

        it 'copies all image attributes' do
          expect([affiliate.aws_header_image_content_type,
                 affiliate.aws_header_image_file_size]).to eq(
                   [affiliate.header_image_content_type, affiliate.header_image_file_size])
          expect([affiliate.aws_header_tagline_logo_content_type, affiliate.aws_header_tagline_logo_file_size]). to eq(
            [affiliate.header_tagline_logo_content_type, affiliate.header_tagline_logo_file_size])
          expect([affiliate.aws_page_background_image_content_type, affiliate.aws_page_background_image_file_size]). to eq(
            [affiliate.page_background_image_content_type, affiliate.page_background_image_file_size])
          expect([affiliate.aws_mobile_logo_content_type, affiliate.aws_mobile_logo_file_size]).to eq(
            [affiliate.mobile_logo_content_type, affiliate.mobile_logo_file_size])
        end

        context 'when not all images are present' do
          let!(:affiliate) do
            affiliate = affiliates(:usagov_affiliate)
            affiliate.update_attributes!(header_image: image)
            affiliate
          end

          it 'succeeds' do
            expect(affiliate.aws_header_image.url).to match /s3\.amazonaws\.com/
          end
        end
      end

      context 'with various image types' do
        let(:png_image) { File.open(Rails.root.join('spec/fixtures/images/corgi_small.png')) }
        let(:pjpeg_image) { File.open(Rails.root.join('spec/fixtures/images/dog.jpg')) }
        let(:gif_image) { File.open(Rails.root.join('spec/fixtures/images/corgi.gif')) }
        let(:xpng_image) { File.open(Rails.root.join('spec/fixtures/images/taxes.png')) }

        before do
          affiliate.header_image = pjpeg_image
          affiliate.header_tagline_logo = png_image
          affiliate.page_background_image = gif_image
          affiliate.mobile_logo = xpng_image
          affiliate.save!
          migrate_affiliate_images
        end

        it 'succeeds' do
          expect(affiliate.reload.aws_header_image_content_type).to eq('image/jpeg')
          expect(affiliate.aws_header_tagline_logo_content_type).to eq('image/png')
          expect(affiliate.aws_page_background_image_content_type).to eq('image/gif')
          expect(affiliate.aws_mobile_logo_content_type).to eq('image/png')
        end
      end
    end


    context 'copying featured_collection images' do
      let!(:fc) do
        fc =  featured_collections(:basic)
        fc.update_attribute(:image, image)
        fc
      end

      subject(:migrate_fc_images) do
        Rake::Task['usasearch:migrate_images'].invoke('featured_collections')
      end

      context 'when the migration succeeds' do
        before { migrate_fc_images }

        it 'saves a copy of the image to AWS' do
          expect(fc.reload.aws_image.url).to match /s3\.amazonaws\.com/
          expect([fc.aws_image_content_type, fc.aws_image_file_size, fc.aws_image.size]).to eq(
            [fc.image_content_type, fc.image_file_size, fc.image.size])
        end
      end

      context 'when the image has already been migrated' do
        before { fc.update_attribute(:aws_image, image) }

        it 'does not re-copy the image' do
          expect{migrate_fc_images}.
            to raise_error(SystemExit, /No records found to update./)
        end
      end

      context 'when something goes wrong' do
        before do
          $stdout = StringIO.new
          FeaturedCollection.any_instance.stub(:save!).
            and_raise StandardError
        end

        after { $stdout = STDOUT }

        it 'rescues and logs the error' do
          migrate_fc_images
          expect($stdout.string).to match /Unable to migrate images for FeaturedCollection #{fc.id}/
          expect($stdout.string).to match /Failed to update images for featured_collections:\n#{fc.id}/
        end

        context 'when the table argument is invalid' do
          it 'aborts and alerts the user' do
            expect { Rake::Task['usasearch:migrate_images'].invoke('wompwomp') }.
              to raise_error(SystemExit, /Table must be featured_collections or affiliates./)
          end
        end

        context 'when the ids are improperly formatted' do
          it 'aborts and alerts the user' do
            expect { Rake::Task['usasearch:migrate_images'].invoke('featured_collections','2,5') }.
              to raise_error(SystemExit, /Ids must be a space-delimited list./)
          end
        end
      end

      context 'when ids are provided' do
        let!(:another_fc) do
          another_fc =  featured_collections(:another)
          another_fc.update_attribute(:image, image)
          another_fc
        end

        subject(:migrate_with_ids) do
          Rake::Task['usasearch:migrate_images'].invoke('featured_collections',fc.id.to_s)
        end

        before { migrate_with_ids }

        it 'copies the image for the specified id' do
          expect(fc.reload.aws_image.url).to_not be_nil
        end

        it 'does not copy other images' do
          expect(another_fc.reload.aws_image_file_name).to be_nil
        end
      end
    end

    context 'when no records need updating' do
     let(:migrate_non_existent_record) do
       Rake::Task['usasearch:migrate_images'].invoke('featured_collections','666')
     end

      it 'aborts and alerts the user' do
        expect{migrate_non_existent_record}.
          to raise_error(SystemExit, /No records found to update./)
      end
    end
  end
end
