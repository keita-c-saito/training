# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Config, type: :model do
  describe 'name validations' do
    let(:maintenance_config) { build(:maintenance_config, name: name) }
    subject { maintenance_config.save }

    context 'blank' do
      let(:name) { '' }
      it 'can not be saved' do
        is_expected.to be_falsy
      end
    end

    context 'when name existed' do
      let!(:existed_config) { create(:maintenance_config) }
      let(:name) { existed_config.name }
      it 'can not be saved' do
        is_expected.to be_falsy
      end
    end
  end
end
