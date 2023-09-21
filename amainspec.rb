control 'Verify AMA direcotry permission' do
title 'Check to ensure greater permission is granted per defult requirement'

describe file("/etc/opt/microsoft/azuremonitoragent/config-cache") do
	it { should be_more_permissive_than('0710') }
	end

direcotries = ["/etc/opt/microsoft/azuremonitoragent/","/var/opt/microsoft/azuremonitoragent/","/var/run/azuremonitoragent/","/opt/microsoft/azuremonitoragent/","/run/azuremonitoragent/"]
direcotries.each do |dir|
    describe file(dir) do
          it { should be_more_permissive_than('0751') }
        end
 end
end

control 'Verify TLS1.2 protocol and TCP/SSL connection' do
title 'Check to ensure AMCS endpoints and LA endpoints are reachable'
        describe ssl(port: 443) do
                its('protocols') { should include 'tls1.2' }
        end

        destinations = ["global.handler.control.monitor.azure.com", input("workspaceId") + ".ods.opinsights.azure.com"]
        destinations.each do |dest|
        describe host(dest, port: 443, protocol: 'tcp') do
                its('connection') { should match /Connected to/ }
        end
        end
		
		commands = ['openssl s_client -connect global.handler.control.monitor.azure.com:443' ,'openssl s_client -connect ' +  input('workspaceId') + ".ods.opinsights.azure.com:443"]
		commands.each do |cmd|
        describe command(cmd) do
                its('stdout') { should include 'Verification: OK' }
    end
	end

end

control 'Verify AMA running process' do
title 'Check to ensure processess are running'

processes = ["amacoreagent","agentlauncher","mdsd","telegraf","MetricsExtension"]
processes.each do |proc|
    describe processes(proc) do
          it { should be_running }
        end
 end
end


control 'Verify ConfigChunk exist' do
title 'Check to ensure config chunk has been synced'

describe command('ls /etc/opt/microsoft/azuremonitoragent/config-cache/configchunks | grep json') do
        its('exit_status') { should eq 0 }
        end
end
