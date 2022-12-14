import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import 'note.dart';

class NoteService extends ChangeNotifier {
  List<Note> notes = [];
  final _rpcUrl = 'http://127.0.0.1:7545',
      _wsUrl = 'ws://127.0.0.1:7545',
      _privateKey =
          '8e1092e7e790d69231f9771f0f36591a097ca201ff3fdd671557d2929874333a';

  late Web3Client _w3Client;
  late ContractAbi _contractAbi;
  late EthereumAddress _contractAddress;
  late EthPrivateKey _creds;
  late DeployedContract _deployedContract;
  late ContractFunction _createNote;
  late ContractFunction _deleteNote;
  late ContractFunction _notes;
  late ContractFunction _noteCount;

  NoteService() {
    init();
  }

  Future<void> init() async {
    _w3Client = Web3Client(
      _rpcUrl,
      http.Client(),
      socketConnector: () => IOWebSocketChannel.connect(_wsUrl).cast<String>(),
    );
    await getCredentials();
    await getABI();
    await getDeployedContracts();
    await fetchNotes();
  }

  Future<void> getABI() async {
    var data =
        await rootBundle.loadString('build/contracts/NotesContract.json');
    var decoded = jsonDecode(data);
    _contractAbi = ContractAbi.fromJson(jsonEncode(decoded['abi']), 'NotesContract');
    _contractAddress =
        EthereumAddress.fromHex(decoded['networks']['5777']['address']);
  }

  Future<void> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> getDeployedContracts() async {
    _deployedContract = DeployedContract(_contractAbi, _contractAddress);
    _createNote = _deployedContract.function('createNote');
    _deleteNote = _deployedContract.function('deleteNote');
    _notes = _deployedContract.function('notes');
    _noteCount = _deployedContract.function('notes_count');
  }

  /// region functions
  Future<void> fetchNotes() async {
    List totalTasksList = await _w3Client.call(
      contract: _deployedContract,
      function: _noteCount,
      params: [],
    );
    int totalTasksLen = totalTasksList[0].toInt();
    notes.clear();
    for (var i = 0; i < totalTasksLen; i++) {
      var temp = await _w3Client.call(
        contract: _deployedContract,
        function: _notes,
        params: [BigInt.from(i)],
      );
      if (temp[1] != "") {
        notes.add(
          Note(
            id: (temp[0] as BigInt).toInt(),
            title: temp[1],
            description: temp[2],
          ),
        );
      }
    }

    notifyListeners();
  }

  Future<void> addNote(String title, String description) async {
    await _w3Client.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _createNote,
        parameters: [title, description],
      ),
    );
    notifyListeners();
    fetchNotes();
  }

  /// endregion
}
