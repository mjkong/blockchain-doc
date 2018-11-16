

##### docker container 중지, 삭제
docker stop $(docker ps -qa ) && docker rm $(docker ps -qa)


###### 샘플 경로
/home/bcadmin/fabric-samples/first-network/

###### Blockchain network 실행
./byfn.sh generate
./byfn.sh up

###### 컨테이너 리스트 확인
docker ps

###### cli 접속 명령
docker exec -it cli bash

###### Blockchain network 중지
./byfn.sh down

###### 채널명 환경변수 셋팅
export CHANNEL_NAME=mychannel

###### chaincode query
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

###### chaincode invoke
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'

==================================  Fabric network custom 설정  ===============================================
##### 기존 설정 파일 삭제하기
rm -rf /channel-artifacts/*

#### 인증서 만들기
../bin/cryptogen generate --config=./crypto-config.yaml

##### genesis block 만들기
export FABRIC_CFG_PATH=$PWD
../bin/configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

##### 채널 아티팩트 만들기
export CHANNEL_NAME=mychannel
../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

##### Anchor peer 아티팩트 만들기
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

##### Fabric Network 시작
docker-compose -f docker-compose-cli.yaml up -d
