import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class BlockchainService {
  /// Sepolia RPC (Infura / Alchemy)
  final String rpcUrl =
      "https://eth-sepolia.g.alchemy.com/v2/mjpZ2GMmtwVHWOPex30BI";

  /// Deployed Contract Address
  final String contractAddress = "0xc53B4e6984b8e59170896f1D9A8d005735823ba6";

  late Web3Client client;
  late DeployedContract contract;
  late ContractFunction recordMessage;

  BlockchainService() {
    client = Web3Client(rpcUrl, Client());

    final abi = jsonDecode(_abiCode);
    contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), "MessageAudit"),
      EthereumAddress.fromHex(contractAddress),
    );

    recordMessage = contract.function("recordMessage");
  }

  /// Send metadata to blockchain
  Future<void> storeMessageMeta({
    required String privateKey,
    required String receiver,
    required String cid,
    required String signature,
    required String prevSignature,
  }) async {
    final credentials = EthPrivateKey.fromHex(privateKey);

    final receiverAddr = EthereumAddress.fromHex(receiver);

    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: recordMessage,
        parameters: [
          receiverAddr,
          cid,
          signature,
          prevSignature,
        ],
      ),
      chainId: 11155111, // Sepolia
    );
  }
}

/// ABI
const String _abiCode = '''
[
 {
  "inputs": [
   {"internalType":"address","name":"_receiver","type":"address"},
   {"internalType":"string","name":"_cid","type":"string"},
   {"internalType":"string","name":"_signature","type":"string"},
   {"internalType":"string","name":"_prevSignature","type":"string"}
  ],
  "name":"recordMessage",
  "outputs":[],
  "stateMutability":"nonpayable",
  "type":"function"
 }
]
''';
