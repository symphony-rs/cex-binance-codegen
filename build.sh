#!/bin/bash

WORK_DIR=$(pwd)

if [ ! -d "simple-binary-encoding" ]; then
    git clone git@github.com:aeron-io/simple-binary-encoding.git --depth 1
    cd simple-binary-encoding && ./gradlew
    cd $WORK_DIR
fi

SCHEMA_BASE=https://raw.githubusercontent.com/binance/binance-spot-api-docs/master/sbe/schemas
# spot api sbe schema
# curl -o spot_latest.xml https://raw.githubusercontent.com/binance/binance-spot-api-docs/master/sbe/schemas/spot_3_1.xml
# spot api sbe schema
curl -o spot_latest.xml $SCHEMA_BASE/$(curl -s $SCHEMA_BASE/spot_prod_latest.xml)
# 修改package属性
sed -i 's/package="spot_sbe"/package="binance_spot_sbe"/g' spot_latest.xml
# 生成rust代码
java --add-opens java.base/jdk.internal.misc=ALL-UNNAMED \
     -Dsbe.target.language=Rust \
     -Dsbe.output.dir=./ \
     -Dsbe.generate.ir=true \
     -jar simple-binary-encoding/sbe-all/build/libs/sbe-all-*.jar \
     spot_latest.xml
# 格式化
cargo clippy --fix -p binance_spot_sbe --allow-dirty --allow-no-vcs -- -D clippy::all

# spot stream sbe schema
curl -o stream_latest.xml $SCHEMA_BASE/stream_1_0.xml
# 修改package属性
sed -i 's/package="spot_stream"/package="binance_spot_stream"/g' stream_latest.xml
# 生成rust代码
java --add-opens java.base/jdk.internal.misc=ALL-UNNAMED \
     -Dsbe.target.language=Rust \
     -Dsbe.output.dir=./ \
     -Dsbe.generate.ir=true \
     -jar simple-binary-encoding/sbe-all/build/libs/sbe-all-*.jar \
     stream_latest.xml
# 格式化
cargo clippy --fix -p binance_spot_stream --allow-dirty --allow-no-vcs -- -D clippy::all
