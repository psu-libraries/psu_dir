# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PsuDir::Disambiguate::Name do
  subject(:resolved_name) { described_class.disambiguate(name) }

  let(:ldap_fields) { %i[uid givenname sn mail eduPersonPrimaryAffiliation displayname] }

  before do
    allow(PsuDir::Disambiguate::User).to receive(:directory_attributes).with(name, ldap_fields).and_return([]) if in_travis
    described_class.clear_cache
  end

  context 'when we have a normal name' do
    let(:name) { 'Thompson, Britta M' }
    let(:response) { format_name_response('bmt13', 'BRITTA MAY', 'THOMPSON', 'FACULTY') }

    it 'finds the user' do
      expect_ldap(:query_ldap_by_name, response, 'Britta M', 'Thompson', ldap_fields)
      expect(resolved_name.count).to eq(1)
    end
  end

  context 'when we have an id' do
    let(:name) { 'cam156' }
    let(:response) do
      resp = format_name_response('cam156', 'CAROLYN A', 'COLE')
      resp[0][:displayname] = [resp[0][:displayname]]
      resp
    end

    it 'finds the ids' do
      expect_ldap(:directory_attributes, response, name, ldap_fields)
      expect(PsuDir::Disambiguate::User).not_to receive(:query_ldap_by_name)
      expect(resolved_name.count).to eq(1)
    end
  end

  context 'when we have multiple combined with an and' do
    let(:name) { 'Carolyn Cole and Adam Wead' }
    let(:response1) { format_name_response('cam156', 'Carolyn Ann', 'Cole') }
    let(:response2) { format_name_response('agw13', 'Adam Garner', 'Wead') }

    it 'finds both users' do
      expect_ldap(:query_ldap_by_name, response1, 'Carolyn', 'Cole', ldap_fields)
      expect_ldap(:query_ldap_by_name, response2, 'Adam', 'Wead', ldap_fields)
      is_expected.to eq([response1.first, response2.first])
    end
  end

  context 'when we have initials for first name' do
    let(:name) { 'A.J. Ostrowski' }
    let(:response) { format_name_response('ajo5254', 'AMANDA JEAN', 'OSTROWSKI', 'STUDENT') }

    it 'finds the user' do
      expect_ldap(:query_ldap_by_name, response, 'A J', 'Ostrowski', ldap_fields)
      is_expected.to eq(response)
    end
  end

  context 'when we have multiple results' do
    let(:name) { 'C Cole' }
    let(:response) do
      [format_name_response('cac13', 'CHARLES ANDREW', 'COLE').first,
       format_name_response('cam156', 'CAROLYN A', 'COLE').first]
    end

    it 'finds the user' do
      expect_ldap(:query_ldap_by_name, response, 'C', 'Cole', ldap_fields)
      is_expected.to eq([])
    end
  end

  context 'when the user has many titles' do
    let(:name) { 'Adam Wead, MSN, RN, CPN' }
    let(:response) { format_name_response('agw13', 'Adam Garner', 'Wead') }

    it 'finds the user' do
      expect_ldap(:query_ldap_by_name, [], 'MSN', 'Adam Wead', ldap_fields)
      expect_ldap(:query_ldap_by_name, [], 'Adam Wead, MSN,', 'RN, CPN', ldap_fields)
      expect_ldap(:query_ldap_by_name, response, 'Adam', 'Wead', ldap_fields)
      is_expected.to eq(response)
    end
  end

  context 'when the user has a title first' do
    let(:name) { 'MSN Deb Cardenas' }
    let(:response) { format_name_response('dac40', 'DEBORAH A.', 'CARDENAS') }

    it 'finds the user' do
      expect_ldap(:query_ldap_by_name, [], 'MSN Deb', 'Cardenas', ldap_fields)
      expect_ldap(:query_ldap_by_name, response, 'Deb', 'Cardenas', ldap_fields)
      is_expected.to eq(response)
    end
  end

  context 'when the user has strange characters' do
    let(:name) { 'Carolyn Cole *' }
    let(:response) { format_name_response('cam156', 'Carolyn Ann', 'Cole', 'STAFF') }

    it 'cleans the name' do
      expect_ldap(:query_ldap_by_name, response, 'Carolyn', 'Cole', ldap_fields)
      is_expected.to eq(response)
    end
  end

  context 'when the user has an apostrophy' do
    let(:name) { "Anthony R. D'Augelli" }
    let(:response) { format_name_response('ard', 'Anthony Raymond', "D'Augelli", 'EMERITUS') }

    it 'finds the user' do
      expect_ldap(:query_ldap_by_name, response, 'Anthony R', "D'Augelli", ldap_fields)
      is_expected.to eq(response)
    end
  end

  context 'when the user has many names' do
    let(:name) { 'ALIDA HEATHER DOHN ROSS' }
    let(:response) { format_name_response('hdr10', 'Alida Heather', 'Dohn Ross') }

    it 'finds the user' do
      expect_ldap(:query_ldap_by_name, [], 'ALIDA HEATHER DOHN', 'ROSS', ldap_fields)
      expect_ldap(:query_ldap_by_name, [], 'DOHN', 'ROSS', ldap_fields)
      expect_ldap(:query_ldap_by_name, response, 'ALIDA HEATHER', 'DOHN ROSS', ldap_fields)
      is_expected.to eq(response)
    end
  end

  context 'when the user has additional information' do
    let(:name) { 'Cole, Carolyn (Kubicki Group)' }
    let(:response) { format_name_response('cam156', 'Carolyn Ann', 'Cole') }

    it 'cleans the name' do
      expect_ldap(:query_ldap_by_name, response, 'Carolyn', 'Cole', ldap_fields)
      is_expected.to eq(response)
    end
  end

  context 'when the user has and as part of their name' do
    let(:name) { 'Amanda Ramcharan' }
    let(:response) { format_name_response('amr418', 'Amanda M', 'Ramcharan', 'FACULTY') }

    it 'cleans the name' do
      expect_ldap(:query_ldap_by_name, response, 'Amanda', 'Ramcharan', ldap_fields)
      is_expected.to eq(response)
    end
  end

  context 'when the user has an email in thier name' do
    context 'when the email is not their id' do
      let(:name) { 'Barbara I. Dewey a bdewey@psu.edu' }
      let(:response) { format_name_response('bid1', 'Barbara Irene', 'Dewey') }

      it 'does not find the user' do
        expect_ldap(:directory_attributes, [], 'Barbara I. Dewey a bdewey@psu.edu', ldap_fields)
        expect_ldap(:directory_attributes, [], 'bdewey', ldap_fields)
        expect_ldap(:query_ldap_by_mail, response, 'bdewey@psu.edu', ldap_fields)
        is_expected.to eq(response)
      end
    end

    context 'when the email is their id' do
      let(:name) { 'sjs230@psu.edu' }
      let(:response) { format_ldap_response('sjs230', 'SARAH J', 'STAGER') }

      it 'finds the user' do
        expect_ldap(:directory_attributes, [], 'sjs230@psu.edu', ldap_fields)
        expect_ldap(:directory_attributes, response, 'sjs230', ldap_fields)
        expect(resolved_name.count).to eq(1)
      end
    end

    context 'when the email is their id' do
      let(:name) { 'sjs230@psu.edu, cam156@psu.edu' }
      let(:response1) { format_ldap_response('sjs230', 'SARAH J', 'STAGER') }
      let(:response2) { format_ldap_response('cam156', 'CAROLYN A', 'cole') }

      it 'finds the user' do
        expect_ldap(:directory_attributes, [], 'sjs230@psu.edu, cam156@psu.edu', ldap_fields)
        expect_ldap(:directory_attributes, response1, 'sjs230', ldap_fields)
        expect_ldap(:directory_attributes, response2, 'cam156', ldap_fields)
        expect(resolved_name.count).to eq(2)
      end
    end

    context 'when name is weird', unless: in_travis do
      let(:name) { 'Brendon Hunt (thesis: Keith Wilson)' }

      it 'does not error' do
        expect(resolved_name.count).to eq(0)
      end
    end

    context 'when name is weird' do
      let(:name) { 'Kenan Ünlü' }

      it 'does not error' do
        expect_ldap(:directory_attributes, [], 'Kenan Ünlü', ldap_fields)
        expect_ldap(:query_ldap_by_name, [], 'Kenan', 'nl', ldap_fields)
        expect(resolved_name.count).to eq(0)
      end
    end

    context 'when name is Shih', unless: in_travis do
      let(:name) { 'Dr. Patrick C. Shih' }

      it 'does not error' do
        expect { resolved_name }.not_to raise_error
        expect(resolved_name.count).to eq(0)
      end
    end
  end
end
