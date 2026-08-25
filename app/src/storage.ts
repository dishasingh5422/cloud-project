import {
  S3Client,
  CreateBucketCommand,
  HeadBucketCommand,
  PutObjectCommand,
  ListObjectsV2Command,
} from "@aws-sdk/client-s3";

const bucket = process.env.S3_BUCKET!;

const s3 = new S3Client({
  region: process.env.AWS_REGION!,
  endpoint: process.env.AWS_ENDPOINT_URL!,
  forcePathStyle: true,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

export async function ensureBucket() {
  try {
    await s3.send(
      new CreateBucketCommand({
        Bucket: bucket,
      })
    );
  } catch (error: any) {
    if (
      error.name !== "BucketAlreadyOwnedByYou" &&
      error.name !== "BucketAlreadyExists"
    ) {
      throw error;
    }
  }
}

export async function uploadText(key: string, content: string) {
  await ensureBucket();

  await s3.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: content,
      ContentType: "text/plain",
    })
  );
}

export async function listObjects() {
  await ensureBucket();

  const result = await s3.send(
    new ListObjectsV2Command({
      Bucket: bucket,
    })
  );

  return result.Contents ?? [];
}