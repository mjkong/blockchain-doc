# Hyperledger Fabric 실습

>> 실습 버전 : Hyperledger Fabric 1.4.3

##### 참조 환경 변수
~~~shell
## peer0.org1
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=peer0.org1.example.com:7051
CORE_PEER_LOCALMSPID=Org1MSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

## peer1.org1
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=peer1.org1.example.com:8051
CORE_PEER_LOCALMSPID=Org1MSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt

## peer0.org2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=peer0.org2.example.com:9051
CORE_PEER_LOCALMSPID=Org2MSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

## peer1.org2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ADDRESS=peer1.org2.example.com:10051
CORE_PEER_LOCALMSPID=Org2MSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
~~~

## First network 실습
먼저 fabric-samples의 first-network를 실행하여 동작을 확인해 보겠습니다.
first-network는 1개의 Orderer, 4개의 Peer(두 개의 조직에 각 2개의 Peer로 구성 됨)로 이루어져 있습니다.

다수의 컨테이너를 쉽게 괸라하기 위해서 docker-compose 툴을 사용하도록 샘플들이 만들어져있습니다.

1. first network 시작

~~~shell
cd fabric-samples/first-network
./byfn.sh up
~~~

위의 명령 실행 후 아래와 같은 결과가 나오면 정상적으로 `first-network`가 실행되었습니다.
![](./images/start_first_network.png)

2. 트랜잭션 실행

CLI 컨테이너에 접속합니다.
~~~shell
docker exec -it cli bash
~~~
![](./images/connect_to_cli.png)

CLI 컨테이너에 접속하였으면 Query 트랜잭션을 실행하여 현재 저장되어 있는 `a,b`의 값을 조회합니다.
~~~shell
export CHANNEL_NAME=mychannel
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","b"]}'
~~~

![](./images/query_transaction.png)

이번에는 Invoke 트랜잭션을 통해 `a,b`의 값을 변경하고 다시 조회해 보겠습니다.
~~~shell
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
~~~

~~~shell
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","b"]}'
~~~

위의 트랜잭션을 실행하여 아래와 같은 결과를 확인 할 수 있습니다.

![](./images/invoke_transaction.png)

현재 설치된 체인코드는 자산의 이동을 아주 간략하게 작성한 체인코드로 체인코드가 초기화 될 때 (instantiate) `a`에 `100`, `b`에 `200` 값을 입력하였습니다.

그리고 `invoke`가 호출 시 마다 `a,b,10`의 인자로 호출하는데 이 때 `a`에서 `10`을 빼서 `b`로 이동하게 됩니다. 

위의 예제에서 한 번의 `invoke` 호출 전 후를 비교해 보시면 알 수 있습니다.
