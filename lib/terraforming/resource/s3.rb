module Terraforming
  module Resource
    class S3
      include Terraforming::Util

      def self.tf(client: Aws::S3::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::S3::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/s3")
      end

      def tfstate
        buckets.inject({}) do |resources, bucket|
          resources["aws_s3_bucket.#{module_name_of(bucket)}"] = {
            "type" => "aws_s3_bucket",
            "primary" => {
              "id" => bucket.name,
              "attributes" => {
                "acl" => "private",
                "bucket" => bucket.name,
                "id" => bucket.name
              }
            }
          }

          resources
        end
      end

      private

      def buckets
        @client.list_buckets.buckets
      end

      def module_name_of(bucket)
        normalize_module_name(bucket.name)
      end
    end
  end
end
