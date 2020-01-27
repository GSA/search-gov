u = User.where(email: 'admin@email.gov').first_or_initialize
u.assign_attributes( contact_name: 'admin',
                     default_affiliate: Affiliate.find_by_name('usagov'),
                     is_affiliate: true,
                     organization_name: 'GSA',
                   )

u.approval_status = 'approved'
u.is_affiliate_admin = true
u.save!
u.affiliate_ids = Affiliate.pluck(:id)
