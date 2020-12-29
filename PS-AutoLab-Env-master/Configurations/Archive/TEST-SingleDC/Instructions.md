# Lab Definition

This lab builds the following:

* 1 DC
* 1 Server (s1)
* 1 Nano (N1)
* 1 Client with RSAT (Cli1)

## To get started:

    To run the full lab setup, which includes Setup-Lab, Run-Lab, Enable-Internet, and Validate-Lab:
    PS> Unattend-Lab

    To run the commands individually to setup the lab environment:

    Run the following for initial setup:
    PS> Setup-Lab

    To start the LAb, and apply configurations the first time:
    PS> Run-Lab

    To enable Internet access for the VM's, run:
    PS> Enable-Internet

    To validate when configurations have converged:
    PS> Validate-Lab

## To Stop and snapshot the lab

    To stop the lab VM's:
    PS> Shutdown-lab

    To checkpoint the VM's:
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
