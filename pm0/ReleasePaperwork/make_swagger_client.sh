#
# Builds a swift 4 cocoapod we use locally.
#
projectsummary='Swagger-Codegen-Output-Swift-4-Library-for-Phaxio-Faxing-Service'
podsummary=${projectsummary}
outputdir=generated/phaxio_swagger_pod
mkdir -p $outputdir
swagger-codegen generate --verbose --model-name-prefix phaxio --lang swift4 --input-spec phaxiospec.yaml  -DprojectName=PhaxioSwiftAlamofire -DpodHomepage=localhost -DprojectDescription=${projectsummary} -DpodSummary=${podsummary} --output $outputdir
