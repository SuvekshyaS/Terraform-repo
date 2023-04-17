
#Create a block volume for data persistence
resource "aws_ebs_volume" "myebs1" {
  availability_zone = aws_instance.Web[0].availability_zone
  size              = 1
  tags = {
    Name = "ebsvol"
  }
}

#Attach the volume to your instance
resource "aws_volume_attachment" "attach_ebs" {
  depends_on   = [aws_ebs_volume.myebs1]
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.myebs1.id
  instance_id  = aws_instance.Web[0].id
  Force_detach = true
}


# Mount the volume to your instance
resource "null_resource" "nullmount" {
  depends_on = [aws_volume_attachment.attach_ebs]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.web_key.private_key_pem
    host        = aws_instance.Web[0].public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4/dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/zTrix/webpage2html"
    ]
  }
}




#Define S3 ID
locals {
  s3_origin_id = "s3-origin"
}

# Create a bucket to upload your static data like images
resource "aws_s3_bucket" "my_suvu984629345" {
  bucket = "my_suvu984629345"
  acl    = "public-read-write"
  region = "ap-southeast-1"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "my_suvu984629345"
    Environment = "Prod"
  }
  provisioner "local-exec" {
    command = "git clone https://github.com/SuvekshyaS web-server-image"
  }
}

#Allow public access to the bucket
resource "aws_s3_bucket_public_access_block" "public_storage" {
  depends_on          = [aws_s3_bucket.my_suvu984629345]
  bucket              = "my_suvu984629345"
  block_public_acls   = false
  block_public_policy = false
}

# Upload your data to S3 bucket
resource "aws_s3_bucket_object" "Object1" {
  depends_on = [aws_s3_bucket.my_suvu984629345]
  bucket     = "my_suvu984629345"
  acl        = "public-read-write"
  key        = "Demo1.png"
  source     = "web-server-image/Demo1.png"
}



#Create a Cloudfront distribution for CDN
resource "aws_cloudfront_distribution" "tera-cloudfront1" {
  depends_on = [aws_s3_bucket.Object1]
  origin {

  }
}

