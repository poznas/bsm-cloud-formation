process.env.PATH = process.env.PATH + ':' + process.env['LAMBDA_TASK_ROOT']

const AWS = require('aws-sdk')
const { spawn, spawnSync } = require('child_process')
const fs = require('fs')
const s3 = new AWS.S3()

const ffProbePath = '/opt/nodejs/ffprobe'
const ffmpegPath = '/opt/nodejs/ffmpeg'
const videoTypes = ['mov', 'mpg', 'mpeg', 'mp4', 'wmv', 'avi', 'webm']
const width = process.env.WIDTH
const height = process.env.HEIGHT

const ffProbeArgs = [
  '-v',
  'error',
  '-show_entries',
  'format=duration',
  '-of',
  'default=nw=1:nk=1',
]

module.exports.handler = async (event, context) => {

  const srcKey = decodeURIComponent(event.Records[0].s3.object.key)
  const bucket = event.Records[0].s3.bucket.name

  await downloadFileFromS3(bucket, srcKey, srcKey.split('/').pop())
    .then(filePath => {

      if (isVideo(srcKey)) {
        const ffProbe = spawnSync(ffProbePath, [...ffProbeArgs, filePath])
        const duration = Math.ceil(ffProbe.stdout.toString())

        return generateVideoThumbnailAt(filePath, duration * 0.1)
      }
      return generatePhotoThumbnail(filePath)
    })
    .then(thumbnailFilePath => {
      const dstKey = srcKey.replace(/\.\w+$/, `-thumbnail.jpg`)
      return uploadFileToS3(bucket, dstKey, thumbnailFilePath, `image/jpg`)
    })
}

const downloadFileFromS3 = (bucket, fileKey, filePath) => {
  'use strict'
  console.log('downloading', bucket, fileKey, filePath)
  return new Promise(function (resolve, reject) {
    const file = fs.createWriteStream(filePath),
      stream = s3.getObject({
        Bucket: bucket,
        Key: fileKey
      }).createReadStream()
    stream.on('error', reject)
    file.on('error', reject)
    file.on('finish', function () {
      console.log('downloaded', bucket, fileKey)
      resolve(filePath)
    })
    stream.pipe(file)
  })
}

const uploadFileToS3 = (bucket, fileKey, filePath, contentType) => {
  'use strict'
  console.log('uploading', bucket, fileKey, filePath)
  return s3.upload({
    Bucket: bucket,
    Key: fileKey,
    Body: fs.createReadStream(filePath),
    ContentType: contentType
  }).promise()
}

const generatePhotoThumbnail = (inputImageFilePath) =>
  generateThumbnail([
    '-i',
    inputImageFilePath,
    '-vf',
    `scale=${width}:${height}`
  ])

const generateVideoThumbnailAt = (inputMovieFilePath, seek) =>
  generateThumbnail([
    '-ss',
    seek,
    '-i',
    inputMovieFilePath,
    '-vf',
    `thumbnail,scale=${width}:${height}`,
    '-qscale:v',
    '2',
    '-frames:v',
    '1',
    '-f',
    'image2',
    '-c:v',
    'mjpeg',
    'pipe:1'
  ])

const generateThumbnail = (args) =>
  new Promise((resolve, reject) => {
    const thumbnailFilePath = `/tmp/screenshot.jpg`
    let tmpFile = fs.createWriteStream(thumbnailFilePath)
    const ffmpeg = spawn(ffmpegPath, args)

    ffmpeg.stdout.pipe(tmpFile)

    ffmpeg.on('close', code => {
      console.log('ffmpeg process end with ' + code)
      tmpFile.end()
      resolve(thumbnailFilePath)
    })

    ffmpeg.on('error', err => {
      console.log(err)
      reject()
    })
  })

const isVideo = (bucketKey) => {

  let fileType = bucketKey.match(/\.\w+$/)

  if (!fileType) {
    throw new Error(`invalid file type found for key: ${bucketKey}`)
  }
  fileType = fileType[0].slice(1)
  return videoTypes.indexOf(fileType) !== -1
}

