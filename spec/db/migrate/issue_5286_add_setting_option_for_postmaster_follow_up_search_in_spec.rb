# Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe AddSettingOptionForPostmasterFollowUpSearchIn, type: :db_migration do

  before do

    # restore old setting
    Setting.create_or_update(
      title:       'Additional follow-up detection',
      name:        'postmaster_follow_up_search_in',
      area:        'Email::Base',
      description: 'By default, the follow-up check is done via the subject of an email. This setting lets you add more fields for which the follow-up check will be executed.',
      options:     {
        form: [
          {
            display:   '',
            null:      true,
            name:      'postmaster_follow_up_search_in',
            tag:       'checkbox',
            options:   {
              'references' => 'References - Search for follow-up also in In-Reply-To or References headers.',
              'body'       => 'Body - Search for follow-up also in mail body.',
              'attachment' => 'Attachment - Search for follow-up also in attachments.',
            },
            translate: true,
          },
        ],
      },
      state:       [],
      preferences: {
        permission: ['admin.channel_email', 'admin.channel_google', 'admin.channel_microsoft365'],
      },
      frontend:    false
    )
  end

  it 'does update settings with new option' do
    expect { migrate }.to change { Setting.find_by(name: 'postmaster_follow_up_search_in').options[:form][0][:options] }.to have_key('subject_references')
  end

  it 'does update settings with new default setting' do
    expect { migrate }.to change { Setting.get('postmaster_follow_up_search_in') }.to ['subject_references']
  end
end
