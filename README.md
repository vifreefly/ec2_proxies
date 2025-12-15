# EC2 Proxies

Create FREE HTTPS/SOCKS5 proxy servers using AWS Free Tier EC2 instances automatically on demand with Terraform and simple HTTP API.

## Why Use EC2 for Proxy Servers?

For scraping purposes, you may need good quality proxies every day for 1–2 hours when web crawlers are running — not 24 hours per day. This makes AWS EC2 instances an ideal choice for on-demand proxy servers that you create and destroy as needed.

* **Cost-effective**: Use AWS Free Tier to run proxy servers at no cost (with limits)
* **Fresh IPs**: Each new instance gets a random IPv4 address from AWS's pool, providing fresh proxy IPs for every new web scraping session
* **Scalable**: Run up to 20 EC2 instances simultaneously
* **On-demand**: Create and destroy proxy servers via Terraform or HTTP API

### AWS Free Tier limits

New AWS accounts receive **$200 in credits** ($100 at signup + $100 for completing onboarding tasks), valid for **6 months** or until credits are exhausted.

#### Eligible Instance Types

`t3.micro`, `t3.small`, `t4g.micro`, `t4g.small`, `c7i-flex.large`, `m7i-flex.large`

> This project uses `t3.micro` instances, which are eligible for the AWS Free Tier.

#### Cost Calculation: Running 20 Proxies for 1 Hour Daily

| Resource | Calculation | Monthly Cost |
|----------|-------------|--------------|
| EC2 t3.micro | 20 instances × 1 hour × 30 days × $0.0104/hr | ~$6.24 |
| Public IPv4 | 20 IPs × 1 hour × 30 days × $0.005/hr | $3.00 |
| Data Transfer | ~10 GB outbound × $0.09/GB | ~$0.90 |
| **Total** | | **~$10.14/month** |

**6-Month Total**: ~$60.84 — **easily covered by $200 free credits** ✅

> Actual costs may vary by region. The calculation above uses `us-east-1` pricing.

---

**Tools:**
* [Terraform](https://www.terraform.io/) to automatically create/install software/destroy EC2 instances
* Proxy server tool - [Goproxy](https://github.com/snail007/goproxy)
* Ubuntu 24.04 LTS for EC2 instances
* Systemd to convert goproxy process to the system daemon service
* Ruby [Sinatra gem](http://sinatrarb.com/) for optional HTTP API to manage proxy instances


## Getting Started
### Installation

On your local machine:

1. Clone the repo: `$ git clone https://github.com/vifreefly/ec2_proxies.git`
2. Install [CLI Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli):

For macOS:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

For Linux see https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli 

3. Run `$ terraform init` inside of project directory.

### Configuration

1. Provide your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` credentials to manage EC2 instances. It is good practice to have separate user roles with restricted permissions for different projects.

[Check here](https://vifreefly.github.io/tech/how-to-create-aws-restricted-credentials-example-for-s3) how to create a new AWS user role and copy credentials. You'll need a user role with `AmazonEC2FullAccess` permission. Then create file `terraform.tfvars` (inside of project directory) and put there `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, example:

```
AWS_ACCESS_KEY_ID="78J347ZVBPY5R4EPXYGQ"
AWS_SECRET_ACCESS_KEY="WvrNVw38ZJT8pbMV6Vy75RQuLoBdgW6ijtRLMgdt"
```

2. Generate SSH key pair for EC2 instances and save it to the .ssh subfolder: `$ ssh-keygen -f .ssh/ec2_key -N ''`

### Settings

All default settings located in the `config.tf` file. If you want to change the value of variable, don't edit `config.tf` file, instead put your configuration to the `terreform.tfvars` file (create this file if it doesn't exists). Use format `VARIABLE_NAME="value"` inside of `terreform.tfvars` file.

You'll probably want to tweak following settings:

* `AWS_INSTANCES_COUNT` - the number of proxy servers to create. Default is 5.
* `AWS_DEFAULT_REGION` - region of instances (proxy servers) where they will be created. Default is `us-east-1`. Check [available regions here](https://docs.aws.amazon.com/general/latest/gr/rande.html#ec2_region). Keep in mind that `AWS_INSTANCE_AMI` should match AWS_DEFAULT_REGION. You can find required AWS_INSTANCE_AMI for a specific region here: <https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LaunchInstances:>
* `PROXY_TYPE` - type of proxy servers. Default is `socks` (socks5). If you need HTTP/HTTPS anonymous proxy instead, set variable to `http`.
* `PROXY_PORT` - port of proxy servers. Default is `46642`.
* `PROXY_USER` and `PROXY_PASSWORD` - set these variables if you want proxy servers use authorization. Defaut is empty (proxy without authorization).

### Usage
#### Command line
##### apply

Command `$ terraform apply` will create EC2 instances and make instances setup (install and run goproxy server). From output you'll get IP addresses of created instances. Example:

```
$ terraform apply
...

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

instances = [
    54.225.911.634,
    31.207.37.49,
    53.235.228.205,
    52.31.233.217,
    35.213.244.142
]
```

Use these IP addresses to connect to proxy servers (proxy type, port and user/password settings were applied from config.tf, see Settings above).

##### output

Command `$ terraform output` will print IP addresses of created instances. Example:

```
$ terraform output

instances = [
    54.225.911.634,
    31.207.37.49,
    53.235.228.205,
    52.31.233.217,
    35.213.244.142
]
```

##### destroy

Command `$ terraform destroy` will destroy all created instances. Example:

```
$ terraform destroy
...

aws_instance.ProxyNode[4]: Destruction complete after 57s
aws_instance.ProxyNode[0]: Destruction complete after 57s
aws_instance.ProxyNode[3]: Destruction complete after 57s
aws_instance.ProxyNode[2]: Destruction complete after 57s
aws_instance.ProxyNode[1]: Destruction complete after 57s
aws_security_group.ec2_proxies_sg: Destroying... (ID: sg-2543a86e)
aws_key_pair.ec2_key: Destroying... (ID: ec2_key)
aws_key_pair.ec2_key: Destruction complete after 2s
aws_security_group.ec2_proxies_sg: Destruction complete after 2s

Destroy complete! Resources: 7 destroyed.
```


#### HTTP API

You can use optional HTTP API to manage proxy servers from your web scrapers codebase, for example when you start running your scrapers you call local API to create proxy servers and when you finish running your scrapers you call API to destroy proxy servers.

<details/>
  <summary>Installation (click to expand)</summary><br>

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/): `$ brew install ruby`
2. Install [Bundler](https://bundler.io/): `$ gem install bundler`
3. Install dependencies: `$ bundle install`

</details><br>

First, start the API server: `$ RACK_ENV=production HOST=127.0.0.1 bundle exec ruby app.rb`. API will be available on `http://localhost:4567`.

##### POST /api/v1/apply

Make post request `/api/v1/apply` to create proxy servers. Configuration in `config.tf` will be used to create instances.

You can pass additional parameters in request body to apply custom settings: `aws_instances_count`, `proxy_type`, `proxy_port`, `proxy_user` and `proxy_password`.

Example:

```
$ curl -X POST http://localhost:4567/api/v1/apply -d 'proxy_type=http&proxy_port=5555&aws_instances_count=3&proxy_user=admin&proxy_password=123456'

{
  "status": "Ok",
  "message": "Successfully performed apply action",
  "data": {
    "instances": [
      "57.94.21.138",
      "28.206.169.144",
      "44.240.61.89"
    ]
  }
}
```

##### GET /api/v1/instances_list

Make get request `/api/v1/instances_list` to get IP addresses of created proxy servers. Example:

```
$ curl -X GET http://localhost:4567/api/v1/instances_list

{
  "status": "Ok",
  "message": "Running 3 instances",
  "data": {
    "instances": [
      "57.94.21.138",
      "28.206.169.144",
      "44.240.61.89"
    ]
  }
}
```

##### POST /api/v1/destroy

Make post request `/api/v1/destroy` to destroy all proxy servers. Example:

```
$ curl -X POST http://localhost:4567/api/v1/destroy

{
  "status": "Ok",
  "message": "Successfully performed destroy action"
}
```

## License

[MIT](https://opensource.org/licenses/MIT)
