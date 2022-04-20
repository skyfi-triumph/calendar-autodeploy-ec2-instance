### Do-it-yourself Cloud Gaming

Stadia, Luna, GeForce now? Limited libraries. Plus you have your own on Steam, GOG, etc. Monthly lock-in prices, this solution lets you pay by the hour of play. Read more [justification here](./docs/why-diy.md)

This terraform module provisions a gaming PC in AWS. You can then use that for cloud-gaming, both traditional or VR (Quest 2). [Notes: Original blog post](./docs/notes.md#original-blog-post).

## On localhost (Mac, PC, whatever)

1. Clone this repo, setup AWS. See [Notes: Non-tech people](./docs/notes.md#non-tech-people)
1. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started). 
1. Edit `terraform.tfvars` with any edits you want. The documentation for all these variables is in `variables.tf`, read through that!
1. `terraform init; terraform apply`. Review the modifications, `yes`. This will take a long time because it's waiting for infrastructure > EC2 instance > boot up > password available for decrypt.

It will output your login credentials to your new Windows PC. Use [Remote Desktop (RDP)](https://support.microsoft.com/en-us/windows/how-to-use-remote-desktop-5fe128d5-8fb1-7a23-3b8a-41e636865e8c) to log in. Enter the connection info outputed from Terraform in terminal (IP, Administrator, Password). [Note: Nice DCV woes](./docs/notes.md#nicedcv-woes)

## On Windows Server (through RDP)

Open `Server Manager` on Windows
1. Disable [IE enahanced security](https://docs.osisoft.com/bundle/ocs/page/add-organize-data/collect-data/connectors/pi-to-ocs/set-up-pi-to-ocs/disable-ie-security.html#:~:text=In%20the%20Properties%20section%2C%20locate,Select%20OK.). [Notes: IE Enhanced Security](./docs/notes#ie-enhanced-security)
   1. Local Server → Properties → IE Enhanced Security: Administrators=off
1. Enable "Wireless Lan". Needed for streaming stuff
   1. Add roles and features
   1. Click through until you get to Features
      1. Checkbox Wireless LAN Service feature
   1. Click Next to move to the end to install the feature
1. Reboot the EC2 instance in order to complete the installation of the new feature.

Download everything; eg Chrome, Steam, etc. Don

## Game streaming!

Now the setup work is done, time to get streaming. [Read ./streaming_setup.md](./streaming_setup.md)

## When you're done

See the output from Terraform terminal, it gives a command to stop your instance. That way you're not paying for the instance when you're not using it (free when it's shut-down). Or you can stop the instance inside Windows Server (Start > Shut Down). Don't terminate the instance, you'll lose it! You won't be charged for shut-down instances in AWS, so just boot it up later when you wanna play.

## Without Terraform

If you don't have a computer to do this from, you can do it all through mobile / whatever. I'll write instructions later, but I recommend looking through the Terraform files and the original blog post to mind-translate the code steps to manual console.aws.com steps. It'll be much harder in console, Terraform strings things together that's not explicit in the code files (eg, Internet Gateway, Route Tables, etc); so if you can use Terraform, please do.

## Gotchas

If your AWS account is new (eg, you set it up for this), see [Notes: AWS Gotchas](./docs/notes#aws-gotchas). Actually, you may wanna read that anyway.