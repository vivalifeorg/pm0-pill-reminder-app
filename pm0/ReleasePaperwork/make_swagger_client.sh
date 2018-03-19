#
# Builds a swift 4 cocoapod we use locally.
#
outputdir=generated/phaxio_swagger_pod
mkdir -p $outputdir
swagger-codegen generate --verbose --model-name-prefix phaxio --lang swift4 --input-spec phaxiospec.yaml  -DprojectName=PhaxioSwiftAlamofire --output $outputdir
