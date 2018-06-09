# AWS EC2 proxies by demand

For scraping purposes I need a good quality proxies everyday for a 1-2 hours when my crawlers are running. I don't need proxies in other time.
So it is makes sence to use AWS EC2 instances for creating proxy servers on demand (automatically of course, within API) and after job is done - destroy them.

Benefits of this approach:
1. If you are not reached AWS Free Tier yet, this means that you have 750 hours and 15 gb of outbount traffic per mouth for free for any count of EC2 servers. For example you'll get only 600 hours per month if you need 20 proxies per day for an one hour (20*30 = 600).
2. If you'll exceed 15 gb free limit (per mounth) of outbound traffic, AWS will charge you only 0.01$ per additional gb.
3. Each new instance (or instance which was stopped and started again) will get a random IPv4 from Amazon pool, so each time we'll have fresh proxies.


Tools:
* Terraform for automatically create, install software and destroy EC2 instances
* Simple web API (builded by Ruby's sinatra framework) to manage terraform commands and get IP addresses of created proxies.

Before:
* create restricted AWS user with permission to manage EC2 instances (enable `AmazonEC2FullAccess` policy)
* Create ssh key pair and save private key to the working directory https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#KeyPairs
* Install terraform https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean#install-terraform (required) and ruby (for web API, not required if you don't need an API)

