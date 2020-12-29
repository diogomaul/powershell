<# Notes:

Authors: Jason Helmick and Melissa (Missy) Januszko

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko.
Currently on her public DSC hub located here:
https://github.com/majst32/DSC_public.git

Goal - Create a Domain Controller, Populute with OU's Groups and Users.
       One Server joined to the new domain
       One Windows 10 CLient joined to the new domain

       

Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#> 

Configuration AutoLab {

    param (
        [Parameter()] 
        [ValidateNotNull()] 
        [PSCredential] $Credential = (Get-Credential -Credential Administrator)
    )

#region DSC Resources
    Import-DSCresource -ModuleName PSDesiredStateConfiguration,
        @{ModuleName="xActiveDirectory";ModuleVersion="2.13.0.0"},
        @{ModuleName="xComputerManagement";ModuleVersion="1.8.0.0"},
        @{ModuleName="xNetworking";ModuleVersion="3.0.0.0"},
        @{ModuleName="xDhcpServer";ModuleVersion="1.5.0.0"},
        @{ModuleName="xADCSDeployment";ModuleVersion="1.0.0.0"}

#endregion

    node $AllNodes.Where({$true}).NodeName {
#region LCM configuration
       
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyOnly'
        }

#endregion
  
#region IPaddress settings 

    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($node.DomainName)\$($Credential.UserName)", $Credential.Password)

    If (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {
        xIPAddress 'PrimaryIPAddress' {
            IPAddress      = $node.IPAddress
            InterfaceAlias = $node.InterfaceAlias
            PrefixLength     = $node.SubnetMask
            AddressFamily  = $node.AddressFamily
        }

        If (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {     
            xDefaultGatewayAddress 'PrimaryDefaultGateway' {
                InterfaceAlias = $node.InterfaceAlias
                Address = $node.DefaultGateway
                AddressFamily = $node.AddressFamily
            }
        }

        If (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {                    
            xDnsServerAddress 'PrimaryDNSClient' {
                Address        = $node.DnsServerAddress
                InterfaceAlias = $node.InterfaceAlias
                AddressFamily  = $node.AddressFamily
            }
        }

        If (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {
            xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
                InterfaceAlias = $node.InterfaceAlias
                ConnectionSpecificSuffix = $node.DnsConnectionSuffix
            }
        }
    } #End IF
            
#endregion

#region Firewall Rules
        
        xFirewall 'FPS-ICMP4-ERQ-In' {
            Name = 'FPS-ICMP4-ERQ-In'
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }

        xFirewall 'FPS-ICMP6-ERQ-In' {
            Name = 'FPS-ICMP6-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }

        xFirewall 'FPS-SMB-In-TCP' {
            Name = 'FPS-SMB-In-TCP'
            DisplayName = 'File and Printer Sharing (SMB-In)'
            Description = 'Inbound rule for File and Printer Sharing to allow Server Message Block transmission and reception via Named Pipes. [TCP 445]'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }
#endregion

    } #end nodes ALL

#region Domain Controller config

    node $AllNodes.Where({$_.Role -eq 'DC'}).NodeName {
         
        xComputer ComputerName { 
            Name = $Node.NodeName 
        }            

        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'DNS',
                'RSAT-DNS-Server'                           
                'AD-Domain-Services'
                'GPMC',
                'RSAT-AD-Tools' 
                'RSAT-AD-PowerShell'
                'RSAT-AD-AdminCenter'
                'RSAT-ADDS-Tools'

            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
            }
        } #End foreach

            xADDomain FirstDC {
                DomainName = $Node.DomainName
                DomainAdministratorCredential = $Credential
                SafemodeAdministratorPassword = $Credential
                DatabasePath = $Node.DCDatabasePath
                LogPath = $Node.DCLogPath
                SysvolPath = $Node.SysvolPath 
                DependsOn = '[WindowsFeature]ADDomainServices'
            }  
        
        #Add OU, Groups, and Users

            xWaitForADDomain WaitForADDCRole {
                DomainName = $Node.DomainName
                DependsOn = '[xADDomain]FirstDC'
                RetryIntervalSec = '30'
                RetryCount = '10'
                DomainUserCredential = $DomainCredential
                }

            xADOrganizationalUnit IT {
                Name = 'IT'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]WaitForADDCRole'
                Credential = $DomainCredential
            }

            xADOrganizationalUnit Dev {
                Name = 'Dev'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]WaitForADDCRole'
                Credential = $DomainCredential

            }

            xADOrganizationalUnit Marketing {
                Name = 'Marketing'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]WaitForADDCRole'
                Credential = $DomainCredential

            }

            xADOrganizationalUnit Sales {
                Name = 'Sales'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]WaitForADDCRole'
                Credential = $DomainCredential

            }

            xADOrganizationalUnit Accounting {
                Name = 'Accounting'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]WaitForADDCRole'
                Credential = $DomainCredential

            }

            xADOrganizationalUnit JEA_Operators {
                Name = 'JEA_Operators'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]WaitForADDCRole'
                Credential = $DomainCredential
            }

            xADOrganizationalUnit Servers {
                Name = 'Servers'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]WaitForADDCRole'
                Credential = $DomainCredential
            }

            # Users
            xADUser IT1 {
                DomainName = $node.DomainName
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'MaryL'
                GivenName = 'Mary'
                Surname = 'Lennon'
                DisplayName = 'Mary Lennon'
                Description = 'Main IT'
                Department = 'IT'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]IT'
            }

            xADUser IT2 {
                DomainName = $node.DomainName
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'MikeS'
                GivenName = 'Mike'
                Surname = 'Smith'
                DisplayName = 'Mike Smith'
                Description = 'Backup IT'
                Department = 'IT'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]IT'
            }

            xADUser Dev1 {
                DomainName = $node.DomainName
                Path = "OU=Dev,$($node.DomainDN)"
                UserName = 'SimonS'
                GivenName = 'Simon'
                Surname = 'Smith'
                DisplayName = 'Simon Smith'
                Description = 'The Developer'
                Department = 'Dev'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Dev'
            }

            xADUser Acct1 {
                DomainName = $node.DomainName
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AaronS'
                GivenName = 'Aaron'
                Surname = 'Smith'
                DisplayName = 'Aaron Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Accounting'
            }

            xADUser Acct2 {
                DomainName = $node.DomainName
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AndreaS'
                GivenName = 'Andrea'
                Surname = 'Smith'
                DisplayName = 'Andrea Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Accounting'
            }

            xADUser Acct3 {
                DomainName = $node.DomainName
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AndyS'
                GivenName = 'Andy'
                Surname = 'Smith'
                DisplayName = 'Andy Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Accounting'
            }

            xADUser Sales1 {
                DomainName = $node.DomainName
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SamS'
                GivenName = 'Sam'
                Surname = 'Smith'
                DisplayName = 'Sam Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Sales'
            }

            xADUser Sales2 {
                DomainName = $node.DomainName
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SonyaS'
                GivenName = 'Sonya'
                Surname = 'Smith'
                DisplayName = 'Sonya Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Sales'
            }

            xADUser Sales3 {
                DomainName = $node.DomainName
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SamanthaS'
                GivenName = 'Samantha'
                Surname = 'Smith'
                DisplayName = 'Samantha Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Sales'
            }

            xADUser Market1 {
                DomainName = $node.DomainName
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MarkS'
                GivenName = 'Mark'
                Surname = 'Smith'
                DisplayName = 'Mark Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Marketing'
            }

            xADUser Market2 {
                DomainName = $node.DomainName
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MonicaS'
                GivenName = 'Monica'
                Surname = 'Smith'
                DisplayName = 'Monica Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Marketing'
            }

            xADUser Market3 {
                DomainName = $node.DomainName
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MattS'
                GivenName = 'Matt'
                Surname = 'Smith'
                DisplayName = 'Matt Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]Marketing'
            }

            xADUser JEA1 {
                DomainName = $node.DomainName
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                UserName = 'JimJ'
                GivenName = 'Jim'
                Surname = 'Jea'
                DisplayName = 'Jim Jea'
                Description = 'JEA'
                Department = 'IT'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]JEA_Operators'
            }

            xADUser JEA2 {
                DomainName = $node.DomainName
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                UserName = 'JillJ'
                GivenName = 'Jill'
                Surname = 'Jea'
                DisplayName = 'Jill Jea'
                Description = 'JEA'
                Department = 'IT'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADOrganizationalUnit]JEA_Operators'
            }
            
            #prestage Web Server Computer objects

        [string[]]$WebServers = $Null
        
        foreach ($N in $AllNodes) {
            if ($N.Role -eq "Web") {

                $WebServers = $WebServers + "$($N.NodeName)$"

                xADComputer "CompObj_$($N.NodeName)" {
                    ComputerName = "$($N.NodeName)"
                    DependsOn = '[xADOrganizationalUnit]Servers'
                    DisplayName = $N.NodeName
                    Path = "OU=Servers,$($N.DomainDN)"
                    Enabled = $True
                    DomainAdministratorCredential = $DomainCredential
                    }
                }
            }

            #Groups
            xADGroup ITG1 {
                GroupName = 'IT'
                Path = "OU=IT,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'MaryL', 'MikeS'
                DependsOn = '[xADUser]IT1','[xADUser]IT2'
                Credential = $DomainCredential
            }

            xADGroup SalesG1 {
                GroupName = 'Sales'
                Path = "OU=Sales,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'SamS', 'SonyaS', 'SamanthaS'
                DependsOn = '[xADUser]Sales1','[xADUser]Sales2','[xADUser]Sales3'
                Credential = $DomainCredential
            }

            xADGroup MKG1 {
                GroupName = 'Marketing'
                Path = "OU=Marketing,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'MarkS', 'MonicaS', 'MattS'
                DependsOn = '[xADUser]Market1','[xADUser]Market2','[xADUser]Market3'
                Credential = $DomainCredential
            }

            xADGroup AccountG1 {
                GroupName = 'Accounting'
                Path = "OU=Accounting,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'AaronS', 'AndreaS', 'AndyS'
                DependsOn = '[xADUser]Acct1','[xADUser]Acct2','[xADUser]Acct3'
                Credential = $DomainCredential
            }

            xADGroup JEAG1 {
                GroupName = 'JEA Operators'
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'JimJ', 'JillJ'
                DependsOn = '[xADUser]JEA1','[xADUser]JEA2'
                Credential = $DomainCredential
            }

        If ($WebServers -ne $Null) {
            
            xADGroup WebServerGroup {
                GroupName = 'Web Servers'
                GroupScope = 'Global'
                DependsOn = '[xADOrganizationalUnit]IT'
                Members = $WebServers
                Credential = $EACredential
                Category = 'Security'
                Path = "OU=IT,$($Node.DomainDN)"
                Ensure = 'Present'
                }
            }
       
    } #end nodes DC

#endregion 

#region DHCP
    node $AllNodes.Where({$_.Role -eq 'DHCP'}).NodeName {

        foreach ($feature in @(
                'DHCP',
                'RSAT-DHCP'
            )) {

            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
                DependsOn = '[xADDomain]FirstDC'
            }
        } #End foreach
        
         xWaitForADDomain WaitForADDHCPRole {
                DomainName = $Node.DomainName
                RetryIntervalSec = '30'
                RetryCount = '10'
                DomainUserCredential = $DomainCredential
                DependsOn = '[xADDomain]FirstDC'
                }  
        
        xDhcpServerAuthorization 'DhcpServerAuthorization' {
            Ensure = 'Present';
            DependsOn = '[WindowsFeature]DHCP','[xWaitForADDomain]WaitForADDHCPRole'
        }
        
        xDhcpServerScope 'DhcpScope' {
            Name = $Node.DHCPName;
            IPStartRange = $Node.DHCPIPStartRange
            IPEndRange = $Node.DHCPIPEndRange
            SubnetMask = $Node.DHCPSubnetMask
            LeaseDuration = $Node.DHCPLeaseDuration
            State = $Node.DHCPState
            AddressFamily = $Node.DHCPAddressFamily
            DependsOn = '[WindowsFeature]DHCP'
        }

        xDhcpServerOption 'DhcpOption' {
            ScopeID = $Node.DHCPScopeID
            DnsServerIPAddress = $Node.DHCPDnsServerIPAddress
            Router = $node.DHCPRouter
            AddressFamily = $Node.DHCPAddressFamily
            DependsOn = '[xDhcpServerScope]DhcpScope'
        }  
 
    }
 #end DHCP Config
 #endregion


#region ADCS

    node $AllNodes.Where({$_.Role -eq 'ADCS'}).NodeName {
 
        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'ADCS-Cert-Authority',
                'ADCS-Enroll-Web-Pol',
                'ADCS-Enroll-Web-Svc',
                'ADCS-Web-Enrollment',
                'RSAT-ADCS',
                'RSAT-ADCS-Mgmt'
            )) {

            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
                DependsOn = '[xADDomain]FirstDC'
            }
        } #End foreach  
    
         xWaitForADDomain WaitForADADCSRole {
                DomainName = $Node.DomainName
                RetryIntervalSec = '30'
                RetryCount = '10'
                DomainUserCredential = $DomainCredential
                DependsOn = '[WindowsFeature]ADCSCertAuthority'
                }  
            
        xAdcsCertificationAuthority ADCSConfig
        {
            CAType = $Node.ADCSCAType
            Credential = $Credential
            CryptoProviderName = $Node.ADCSCryptoProviderName
            HashAlgorithmName = $Node.ADCSHashAlgorithmName
            KeyLength = $Node.ADCSKeyLength
            CACommonName = $Node.CACN
            CADistinguishedNameSuffix = $Node.CADNSuffix
            DatabaseDirectory = $Node.CADatabasePath
            LogDirectory = $Node.CALogPath
            ValidityPeriod = $node.ADCSValidityPeriod
            ValidityPeriodUnits = $Node.ADCSValidityPeriodUnits
            DependsOn = '[xWaitForADDomain]WaitForADADCSRole'    
        }

    #Add GPO for PKI AutoEnroll
        script CreatePKIAEGpo
        {
            Credential = $DomainCredential
            TestScript = {
                            if ((get-gpo -name "PKI AutoEnroll" -domain $Using:Node.DomainName -ErrorAction SilentlyContinue) -eq $Null) {
                                return $False
                            } 
                            else {
                                return $True}
                        }
            SetScript = {
                            new-gpo -name "PKI AutoEnroll" -domain $Using:Node.DomainName
                        }
            GetScript = {
                            $GPO= (get-gpo -name "PKI AutoEnroll" -domain $Using:Node.DomainName)
                            return @{Result = $($GPO.DisplayName)}
                        }
            DependsOn = '[xWaitForADDomain]WaitForADADCSRole'   
            }
       
        script setAEGPRegSetting1
        {
            Credential = $DomainCredential
            TestScript = {
                            if ((Get-GPRegistryValue -name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "AEPolicy" -ErrorAction SilentlyContinue).Value -eq 7) {
                                return $True
                            }
                            else {
                                return $False
                            }
                        }
            SetScript = {
                            Set-GPRegistryValue -name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "AEPolicy" -Value 7 -Type DWord
                        }
            GetScript = {
                            $RegVal1 = (Get-GPRegistryValue -name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "AEPolicy")
                            return @{Result = "$($RegVal1.FullKeyPath)\$($RegVal1.ValueName)\$($RegVal1.Value)"}
                        }
            DependsOn = '[Script]CreatePKIAEGpo'
        }

        script setAEGPRegSetting2 
        {
            Credential = $DomainCredential
            TestScript = {
                            if ((Get-GPRegistryValue -name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationPercent" -ErrorAction SilentlyContinue).Value -eq 10) {
                                return $True
                                }
                            else {
                                return $False
                                 }
                         }
            SetScript = {
                            Set-GPRegistryValue -Name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationPercent" -value 10 -Type DWord
                        }
            GetScript = {
                            $Regval2 = (Get-GPRegistryValue -name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationPercent")
                            return @{Result = "$($RegVal2.FullKeyPath)\$($RegVal2.ValueName)\$($RegVal2.Value)"}
                        }
            DependsOn = '[Script]setAEGPRegSetting1'

        }
                               
        script setAEGPRegSetting3
        {
            Credential = $DomainCredential
            TestScript = {
                            if ((Get-GPRegistryValue -Name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationStoreNames" -ErrorAction SilentlyContinue).value -match "MY") {
                                return $True
                                }
                            else {
                                return $False
                                }
                        }
            SetScript = {
                            Set-GPRegistryValue -Name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationStoreNames" -value "MY" -Type String
                        }
            GetScript = {
                            $RegVal3 = (Get-GPRegistryValue -Name "PKI AutoEnroll" -domain $Using:Node.DomainName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationStoreNames")
                            return @{Result = "$($RegVal3.FullKeyPath)\$($RegVal3.ValueName)\$($RegVal3.Value)"}
                        }
            DependsOn = '[Script]setAEGPRegSetting2'
        }
         
        Script SetAEGPLink
        {
            Credential = $DomainCredential
            TestScript = {
                            try {
                                $GPLink = (get-gpo -Name "PKI AutoEnroll" -Domain $Using:Node.DomainName).ID
                                $GPLinks = (Get-GPInheritance -Domain $Using:Node.DomainName -Target $Using:Node.DomainDN).gpolinks | Where-Object {$_.GpoID -like "*$GPLink*"}
                                if ($GPLinks.Enabled -eq $True) {return $True}
                                else {return $False}
                                }
                            catch {
                                Return $False
                                }
                         }
            SetScript = {
                            New-GPLink -name "PKI AutoEnroll" -domain $Using:Node.DomainName -Target $Using:Node.DomainDN -LinkEnabled Yes 
                        }
            GetScript = {
                           $GPLink = (get-gpo -Name "PKI AutoEnroll" -Domain $Using:Node.DomainName).ID
                           $GPLinks = (Get-GPInheritance -Domain $Using:Node.DomainName -Target $Using:Node.DomainDN).gpolinks | Where-Object {$_.GpoID -like "*$GPLink*"}
                           return @{Result = "$($GPLinks.DisplayName) = $($GPLinks.Enabled)"}
                        }
            DependsOn = '[Script]setAEGPRegSetting3'
        }  
        
#region Create and publish templates

#Note:  The Test section is pure laziness.  Future enhancement:  test for more than just existence.
        script CreateWebServer2Template
        {
            DependsOn = '[xAdcsCertificationAuthority]ADCSConfig'
            Credential = $DomainCredential
            TestScript = {
                            try {
                                $WSTemplate=get-ADObject -Identity "CN=WebServer2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -Properties * -ErrorAction Stop
                                return $True
                                }
                            catch {
                                return $False
                                }
                         }
            SetScript = {
                         $WebServerTemplate = @{'flags'='131649';
                        'msPKI-Cert-Template-OID'='1.3.6.1.4.1.311.21.8.8211880.1779723.5195193.12600017.10487781.44.7319704.6725493';
                        'msPKI-Certificate-Application-Policy'='1.3.6.1.5.5.7.3.1';
                        'msPKI-Certificate-Name-Flag'='268435456';
                        'msPKI-Enrollment-Flag'='32';
                        'msPKI-Minimal-Key-Size'='2048';
                        'msPKI-Private-Key-Flag'='50659328';
                        'msPKI-RA-Signature'='0';
                        'msPKI-Supersede-Templates'='WebServer';
                        'msPKI-Template-Minor-Revision'='3';
                        'msPKI-Template-Schema-Version'='2';
                        'pKICriticalExtensions'='2.5.29.15';
                        'pKIDefaultCSPs'='2,Microsoft DH SChannel Cryptographic Provider','1,Microsoft RSA SChannel Cryptographic Provider';
                        'pKIDefaultKeySpec'='1';
                        'pKIExtendedKeyUsage'='1.3.6.1.5.5.7.3.1';
                        'pKIMaxIssuingDepth'='0';
                        'revision'='100'}


                        New-ADObject -name "WebServer2" -Type pKICertificateTemplate -Path "CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -DisplayName WebServer2 -OtherAttributes $WebServerTemplate
                        $WSOrig = Get-ADObject -Identity "CN=WebServer,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -Properties * | Select-Object pkiExpirationPeriod,pkiOverlapPeriod,pkiKeyUsage
                        Get-ADObject -Identity "CN=WebServer2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" | Set-ADObject -Add @{'pKIKeyUsage'=$WSOrig.pKIKeyUsage;'pKIExpirationPeriod'=$WSOrig.pKIExpirationPeriod;'pkiOverlapPeriod'=$WSOrig.pKIOverlapPeriod}
                        }
                GetScript = {
                                try {
                                    $WS2=get-ADObject -Identity "CN=WebServer2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -Properties * -ErrorAction Stop
                                    return @{Result=$WS2.DistinguishedName}
                                    }
                                catch {
                                    return @{Result=$Null}
                                    }
                            }
        }
    

 #Note:  The Test section is pure laziness.  Future enhancement:  test for more than just existence.
        script CreateDSCTemplate
        {
            DependsOn = '[xAdcsCertificationAuthority]ADCSConfig'
            Credential = $Credential
            TestScript = {
                            try {
                                $DSCTemplate=get-ADObject -Identity "CN=DSCTemplate,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -Properties * -ErrorAction Stop
                                return $True
                                }
                            catch {
                                return $False
                                }
                         }
            SetScript = {
                         $DSCTemplateProps = @{'flags'='131680';
                        'msPKI-Cert-Template-OID'='1.3.6.1.4.1.311.21.8.16187918.14945684.15749023.11519519.4925321.197.13392998.8282280';
                        'msPKI-Certificate-Application-Policy'='1.3.6.1.4.1.311.80.1';
                        'msPKI-Certificate-Name-Flag'='1207959552';
                        #'msPKI-Enrollment-Flag'='34';
                        'msPKI-Enrollment-Flag'='32';
                        'msPKI-Minimal-Key-Size'='2048';
                        'msPKI-Private-Key-Flag'='0';
                        'msPKI-RA-Signature'='0';
                        #'msPKI-Supersede-Templates'='WebServer';
                        'msPKI-Template-Minor-Revision'='3';
                        'msPKI-Template-Schema-Version'='2';
                        'pKICriticalExtensions'='2.5.29.15';
                        'pKIDefaultCSPs'='1,Microsoft RSA SChannel Cryptographic Provider';
                        'pKIDefaultKeySpec'='1';
                        'pKIExtendedKeyUsage'='1.3.6.1.4.1.311.80.1';
                        'pKIMaxIssuingDepth'='0';
                        'revision'='100'}


                        New-ADObject -name "DSCTemplate" -Type pKICertificateTemplate -Path "CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -DisplayName DSCTemplate -OtherAttributes $DSCTemplateProps
                        $WSOrig = Get-ADObject -Identity "CN=Workstation,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -Properties * | Select-Object pkiExpirationPeriod,pkiOverlapPeriod,pkiKeyUsage
                        [byte[]] $WSOrig.pkiKeyUsage = 48
                        Get-ADObject -Identity "CN=DSCTemplate,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" | Set-ADObject -Add @{'pKIKeyUsage'=$WSOrig.pKIKeyUsage;'pKIExpirationPeriod'=$WSOrig.pKIExpirationPeriod;'pkiOverlapPeriod'=$WSOrig.pKIOverlapPeriod}
                        }
                GetScript = {
                                try {
                                    $dsctmpl = get-ADObject -Identity "CN=DSCTemplate,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -Properties * -ErrorAction Stop
                                    return @{Result=$dsctmpl.DistinguishedName}
                                    }
                                catch {
                                    return @{Result=$Null}
                                    }
                            }
        }
                  
        script PublishWebServerTemplate2 
        {       
           DependsOn = '[Script]CreateWebServer2Template'
           Credential = $Credential
           TestScript = {
                            $Template= Get-CATemplate | Where-Object {$_.Name -match "WebServer2"}
                            if ($Template -eq $Null) {return $False}
                            else {return $True}
                        }
           SetScript = {
                            add-CATemplate -name "WebServer2" -force
                        }
           GetScript = {
                            $pubWS2 = Get-CATemplate | Where-Object {$_.Name -match "WebServer2"}
                            return @{Result=$pubws2.Name}
                        }
         }
          
          script PublishDSCTemplate 
        {       
           DependsOn = '[Script]CreateDSCTemplate'
           Credential = $Credential
           TestScript = {
                            $Template= Get-CATemplate | Where-Object {$_.Name -match "DSCTemplate"}
                            if ($Template -eq $Null) {return $False}
                            else {return $True}
                        }
           SetScript = {
                            add-CATemplate -name "DSCTemplate" -force
                            write-verbose -Message ("Publishing Template DSCTemplate...")
                        }
           GetScript = {
                            $pubDSC = Get-CATemplate | Where-Object {$_.Name -match "DSCTemplate"}
                            return @{Result=$pubDSC.Name}
                        }
         }
        
                                                   
#endregion - Create and publish templates

#region template permissions
#Permission beginning with 0e10... is "Enroll".  Permission beginning with "a05b" is autoenroll.
#TODO:  Write-Verbose in other script resources.

        [string[]]$Perms = "0e10c968-78fb-11d2-90d4-00c04f79dc55","a05b8cc2-17bc-4802-a710-e7c15ab866a2"

        foreach ($P in $Perms) {

                script "Perms_WebCert_$($P)"
                {
                    DependsOn = '[Script]CreateWebServer2Template'
                    Credential = $DomainCredential
                    TestScript = {
                        Import-Module activedirectory -Verbose:$false
                        $WebServerCertACL = (get-acl "AD:CN=WebServer2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)").Access | Where-Object {$_.IdentityReference -like "*Web Servers"}
                        if ($WebServerCertACL -eq $Null) {
                            write-verbose -message ("Web Servers Group does not have permissions on Web Server template...")
                            Return $False
                            }
                        elseif (($WebServerCertACL.ActiveDirectoryRights -like "*ExtendedRight*") -and ($WebServerCertACL.ObjectType -notcontains $Using:P)) {
                            write-verbose -message ("Web Servers group has permission, but not the correct permission...")
                            Return $False
                            }
                        else {
                            write-verbose -message ("ACL on Web Server Template is set correctly for this GUID for Web Servers Group...")
                            Return $True
                            }
                        }
                     SetScript = {
                        Import-Module activedirectory -Verbose:$false
                        $WebServersGroup = get-adgroup -Identity "Web Servers" | Select-Object SID
                        $EnrollGUID = [GUID]::Parse($Using:P)
                        $ACL = get-acl "AD:CN=WebServer2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)"
                        $ACL.AddAccessRule((New-Object System.DirectoryServices.ExtendedRightAccessRule $WebServersGroup.SID,'Allow',$EnrollGUID,'None'))
                        #$ACL.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $WebServersGroup.SID,'ReadProperty','Allow'))
                        #$ACL.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $WebServersGroup.SID,'GenericExecute','Allow'))
                        set-ACL "AD:CN=WebServer2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -AclObject $ACL
                        write-verbose -Message ("Permissions set for Web Servers Group")
                        }
                     GetScript = {
                        Import-Module activedirectory -Verbose:$false
                        $WebServerCertACL = (get-acl "AD:CN=WebServer2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)").Access | Where-Object {$_.IdentityReference -like "*Web Servers"}
                        if ($WebServerCertACL -ne $Null) {
                            return @{Result=$WebServerCertACL}
                            }
                        else {
                            Return @{}
                            }
                        }
                 }
                      
                script "Perms_DSCCert_$($P)"
                {
                    DependsOn = '[Script]CreateWebServer2Template'
                    Credential = $DomainCredential
                    TestScript = {
                        Import-Module activedirectory -Verbose:$false
                        $DSCCertACL = (get-acl "AD:CN=DSCTemplate,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)").Access | Where-Object {$_.IdentityReference -like "*Domain Computers*"}
                        if ($DSCCertACL -eq $Null) {
                            write-verbose -Message ("Domain Computers does not have permissions on DSC template")
                            Return $False
                            }
                        elseif (($DSCCertACL.ActiveDirectoryRights -like "*ExtendedRight*") -and ($DSCCertACL.ObjectType -notcontains $Using:P)) {
                            write-verbose -Message ("Domain Computers group has permission, but not the correct permission...")
                            Return $False
                            }
                        else {
                            write-verbose -Message ("ACL on DSC Template is set correctly for this GUID for Domain Computers...")
                            Return $True
                            }
                        }
                     SetScript = {
                        Import-Module activedirectory -Verbose:$false
                        $DomainComputersGroup = get-adgroup -Identity "Domain Computers" | Select-Object SID
                        $EnrollGUID = [GUID]::Parse($Using:P)
                        $ACL = get-acl "AD:CN=DSCTemplate,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)"
                        $ACL.AddAccessRule((New-Object System.DirectoryServices.ExtendedRightAccessRule $DomainComputersGroup.SID,'Allow',$EnrollGUID,'None'))
                        #$ACL.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $WebServersGroup.SID,'ReadProperty','Allow'))
                        #$ACL.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $WebServersGroup.SID,'GenericExecute','Allow'))
                        set-ACL "AD:CN=DSCTemplate,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)" -AclObject $ACL
                        write-verbose -Message ("Permissions set for Domain Computers...")
                        }
                     GetScript = {
                        Import-Module activedirectory -Verbose:$false
                        $DSCCertACL = (get-acl "AD:CN=WebServer2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$($Using:Node.DomainDN)").Access | Where-Object {$_.IdentityReference -like "*Domain Computers"}
                        if ($DSCCertACL -ne $Null) {
                            return @{Result=$DSCCertACL}
                            }
                        else {
                            Return @{}
                            }
                        }
                 }
      }   
                        
 
    } #end ADCS Config

#endregion


#region Web config
   node $AllNodes.Where({$_.Role -eq 'Web'}).NodeName {
        
        foreach ($feature in @(
                'web-Server'
 
            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present'
                Name = $feature
                IncludeAllSubFeature = $False
            }
        }
        
    }#end Web Config


#region DomainJoin config
   node $AllNodes.Where({$_.Role -eq 'DomainJoin'}).NodeName {

    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($node.DomainName)\$($Credential.UserName)", $Credential.Password)
 
        xWaitForADDomain DscForestWait {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainCredential
            RetryCount = '20'
            RetryIntervalSec = '60'
        }

         xComputer JoinDC {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $DomainCredential
            DependsOn = '[xWaitForADDomain]DSCForestWait'
        }
    }#end DomainJoin Config
#endregion

#>
} # End AllNodes
#endregion

AutoLab -OutputPath "C:\DSC\Configs" -ConfigurationData .\mj.psd1

