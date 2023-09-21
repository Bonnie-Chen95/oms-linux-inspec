control 'Verify running process' do
title 'Check to ensure core processess are running'

processes = ["omsagent","omiserver","omiagent","omiengine"]
processes.each do |proc|
    describe processes(proc) do
          it { should be_running }
	end
 end
end

control 'Verify root certificate' do
title 'Check to ensure cert.pem is present and valid'
	describe file('/etc/pki/tls/cert.pem') do
		it { should exist }
		its('content') { should include 'Baltimore CyberTrust Root' }
	end
	describe x509_certificate('/etc/pki/tls/cert.pem') do
		it { should be_valid }
	end
end

control 'Verify TLS1.2 protocol and TCP/SSL connection' do
title 'Check to ensure log analytic worksapce endpoints are reachable'
	describe ssl(port: 443) do
		its('protocols') { should include 'tls1.2' }
	end
	
	destinations = [input("workspaceId") + ".oms.opinsights.azure.com", input("workspaceId") + ".ods.opinsights.azure.com", input("workspaceId") + ".agentsvc.azure-automation.net"]
	destinations.each do |dest|
	describe host(dest, port: 443, protocol: 'tcp') do
		its('connection') { should match /Connected to/ }
	end
	end
	
	describe command( 'openssl s_client -connect ' +  input('workspaceId') + ".ods.opinsights.azure.com:443") do
                its('stdout') { should include 'Verification: OK' }
    end

end


control 'Verify Current.mof file existing' do
title 'Check to ensure Current.mof file has been generated'
	describe file('/etc/opt/omi/conf/omsconfig/configuration/Current.mof') do
		it { should exist }
    end
end

