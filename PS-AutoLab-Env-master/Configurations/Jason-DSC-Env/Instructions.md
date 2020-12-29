# Lab Definition

This lab builds the following:

    Computername : DC1
    Description  : Windows Server 2016 Standard Core 64bit English Evaluation
    Role         : {DC, DHCP, ADCS}
    IPAddress    : 192.168.3.10
    MemoryGB     : 2

    Computername : S1
    Description  : Windows Server 2016 Standard Core 64bit English Evaluation
    Role         : {DomainJoin}
    IPAddress    : 192.168.3.50
    MemoryGB     : 1

    Computername : S2
    Description  : Windows Server 2016 Standard Core 64bit English Evaluation
    Role         : {DomainJoin}
    IPAddress    : 192.168.3.51
    MemoryGB     : 1

    Computername : PullServer
    Description  : Windows Server 2016 Standard Core 64bit English Evaluation
    Role         : {DomainJoin}
    IPAddress    : 192.168.3.70
    MemoryGB     : 1

    Computername : Cli1
    Description  : Windows 10 64bit Enterprise 1903 English Evaluation
    Role         : {domainJoin, RSAT, RDP}
    IPAddress    : 192.168.3.100
    MemoryGB     : 2

## To get started

    To run the full lab setup, which includes Setup-Lab, Run-Lab, Enable-Internet, and Validate-Lab:
    PS> Unattend-Lab

    To run the commands individually to setup the lab environment:

    Run the following for initial setup:
    PS> Setup-Lab

    To start the Lab, and apply configurations the first time:
    PS> Run-Lab

    To enable Internet access for the VMs, run:
    PS> Enable-Internet

    To validate when configurations have converged:
    PS> Validate-Lab

## To Stop and snapshot the lab

    To stop the lab VMs:
    PS> Shutdown-lab

    To checkpoint the VMs:
    PS> Snapshot-Lab

    To quickly rebuild the labs from the checkpoint, run:
    PS> Refresh-Lab

## To Patch a lab

    If you want to make sure the virtual machines have the latest updates from Microsoft, you can run this command:

    PS> Update-Lab

    Because this may take some time to run, you can also run it as a background job.

    PS> Update-Lab -asjob

## To remove a lab

    To destroy the lab to build again:
    PS> Wipe-Lab

    You will be prompted for each virtual machine. Or you can force the removal and suppress the prompts:

    PS> Wipe-Lab -force
