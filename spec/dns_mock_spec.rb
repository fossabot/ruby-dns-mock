# frozen_string_literal: true

RSpec.describe DnsMock do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:AVAILABLE_DNS_RECORD_TYPES) }
  end

  describe '.start_server' do
    subject(:dns_mock_server) { described_class.start_server(server_class, **options) }

    let(:server_class) { class_double('DnsMockServer') }

    context 'without keyword args' do
      let(:options) { {} }

      it 'creates and runs DNS mock server instance with default settings' do
        expect(server_class).to receive(:new)
        dns_mock_server
      end
    end

    context 'with keyword args' do
      let(:records) { random_records }
      let(:port) { 42_998 }
      let(:options) { { records: records, port: port, exception_if_not_found: true } }

      it 'creates and runs DNS mock server instance with custom settings' do
        expect(server_class).to receive(:new).with(**options)
        dns_mock_server
      end
    end
  end

  describe '.running_servers' do
    subject(:running_servers) { described_class.running_servers }

    context 'when servers not found' do
      it 'returns empty list of running servers' do
        sleep(0.01)
        expect(running_servers).to be_an_instance_of(::Array)
        expect(running_servers).to be_empty
      end
    end

    context 'when servers found' do
      let(:servers_count) { 2 }

      before { start_random_server(total: servers_count) }

      after { stop_all_running_servers }

      it 'returns list of running servers' do
        expect(running_servers).to be_an_instance_of(::Array)
        expect(running_servers.size).to eq(servers_count)
      end
    end
  end

  describe '.stop_running_servers!' do
    subject(:stop_running_servers) { described_class.stop_running_servers! }

    context 'when servers not found' do
      it { is_expected.to be(true) }
    end

    context 'when servers found' do
      before { start_random_server(total: 2) }

      it { is_expected.to be(true) }
    end
  end

  describe 'DNS mock server integration tests' do
    let(:port) { 5300 }
    let(:ip_address) { random_ip_v4_address }
    let(:rspec_dns_config) { { nameserver: 'localhost', port: port } }

    before { described_class.start_server(records: records, port: port) }

    after { stop_all_running_servers }

    context 'when not internationalized records' do
      let(:domain) { random_hostname }
      let(:records) { create_records(domain).merge(create_records(ip_address, :ptr)) }
      let(:records_by_domain) { records[domain] }
      let(:records_by_ip_address) { records[ip_address] }

      it 'returns predefined A record' do
        expect(domain).to have_dns
          .with_type('A')
          .and_address(records_by_domain[:a].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined AAAA record' do
        expect(domain).to have_dns
          .with_type('AAAA')
          .and_address(records_by_domain[:aaaa].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined NS record' do
        expect(domain).to have_dns
          .with_type('NS')
          .and_domainname(records_by_domain[:ns].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined host name PTR record' do
        expect(domain).to have_dns
          .with_type('PTR')
          .and_domainname(records_by_domain[:ptr].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined host address PTR record' do
        expect(ip_address).to have_dns
          .with_type('PTR')
          .and_domainname(records_by_ip_address[:ptr].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined MX record' do
        expect(domain).to have_dns
          .with_type('MX')
          .and_exchange(records_by_domain[:mx].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined TXT record' do
        expect(domain).to have_dns
          .with_type('TXT')
          .and_data(records_by_domain[:txt].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined CNAME record' do
        expect(domain).to have_dns
          .with_type('CNAME')
          .and_domainname(records_by_domain[:cname])
          .config(**rspec_dns_config)
      end

      it 'returns predefined SOA record' do
        soa_record = records_by_domain[:soa].first

        expect(domain).to have_dns
          .with_type('SOA')
          .and_mname(soa_record[:mname])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_rname(soa_record[:rname])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_serial(soa_record[:serial])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_refresh(soa_record[:refresh])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_retry(soa_record[:retry])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_expire(soa_record[:expire])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_minimum(soa_record[:minimum])
          .config(**rspec_dns_config)
      end
    end

    context 'when internationalized records' do
      let(:domain) { random_non_ascii_hostname }
      let(:records) { create_records(domain).merge(create_records(ip_address, ptr: [random_non_ascii_hostname])) }
      let(:records_by_domain) { records[domain] }
      let(:records_by_ip_address) { records[ip_address] }

      it 'returns predefined A record' do
        expect(domain).to have_dns
          .with_type('A')
          .and_address(records_by_domain[:a].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined AAAA record' do
        expect(domain).to have_dns
          .with_type('AAAA')
          .and_address(records_by_domain[:aaaa].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined NS record' do
        expect(domain).to have_dns
          .with_type('NS')
          .and_domainname(to_punycode_hostname(records_by_domain[:ns].first))
          .config(**rspec_dns_config)
      end

      it 'returns predefined host name PTR record' do
        expect(domain).to have_dns
          .with_type('PTR')
          .and_domainname(to_punycode_hostname(records_by_domain[:ptr].first))
          .config(**rspec_dns_config)
      end

      it 'returns predefined host address PTR record' do
        expect(to_rdns_hostaddress(ip_address)).to have_dns
          .with_type('PTR')
          .and_domainname(to_punycode_hostname(records_by_ip_address[:ptr].first))
          .config(**rspec_dns_config)
      end

      it 'returns predefined MX record' do
        expect(domain).to have_dns
          .with_type('MX')
          .and_exchange(to_punycode_hostname(records_by_domain[:mx].first))
          .config(**rspec_dns_config)
      end

      it 'returns predefined TXT record' do
        expect(domain).to have_dns
          .with_type('TXT')
          .and_data(records_by_domain[:txt].first)
          .config(**rspec_dns_config)
      end

      it 'returns predefined CNAME record' do
        expect(domain).to have_dns
          .with_type('CNAME')
          .and_domainname(to_punycode_hostname(records_by_domain[:cname]))
          .config(**rspec_dns_config)
      end

      it 'returns predefined SOA record' do
        soa_record = records_by_domain[:soa].first

        expect(domain).to have_dns
          .with_type('SOA')
          .and_mname(to_punycode_hostname(soa_record[:mname]))
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_rname(to_punycode_hostname(soa_record[:rname]))
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_serial(soa_record[:serial])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_refresh(soa_record[:refresh])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_retry(soa_record[:retry])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_expire(soa_record[:expire])
          .config(**rspec_dns_config)
        expect(domain).to have_dns
          .with_type('SOA')
          .and_minimum(soa_record[:minimum])
          .config(**rspec_dns_config)
      end
    end

    context 'when records not found' do
      let(:records) { {} }

      it 'returns empty answer for not found record' do
        expect(random_hostname).not_to have_dns
          .with_type('A')
          .and_address(random_ip_v4_address)
          .config(**rspec_dns_config)
      end
    end
  end
end
