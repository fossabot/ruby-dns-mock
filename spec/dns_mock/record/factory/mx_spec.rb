# frozen_string_literal: true

RSpec.describe DnsMock::Record::Factory::Mx do
  it { expect(described_class).to be < DnsMock::Record::Factory::Base }

  describe '#instance_params' do
    subject(:instance_params) { described_class.new(dns_name, record_data: record_data).instance_params }

    let(:dns_name) { class_double('DnsName') }
    let(:dns_name_instance) { instance_double('DnsName') }
    let(:record_data) { %w[mx_preference mx_domain] }

    it 'returns prepared target class instance params' do
      expect(dns_name).to receive(:create).with("#{record_data.last}.").and_return(dns_name_instance)
      expect(instance_params).to eq([record_data.first, dns_name_instance])
    end
  end

  describe '#create' do
    subject(:create_factory) { described_class.new(record_data: record_data).create }

    context 'when valid record context' do
      let(:record_data) { [10, random_hostname] }

      it 'returns instance of target class' do
        expect(create_factory).to be_an_instance_of(described_class.target_class)
        expect(create_factory.preference).to eq(record_data.first)
        expect(create_factory.exchange.to_s).to eq(record_data.last)
      end
    end

    context 'when invalid record context' do
      let(:record_data) { [1, 2] }
      let(:error_context) { "cannot interpret as DNS name: #{record_data.last}. Invalid MX record context" }

      it_behaves_like 'target class exception wrapper'
    end
  end
end
