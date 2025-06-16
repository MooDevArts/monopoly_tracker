import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PayScreen extends StatefulWidget {
  final String gameId;
  final String fromPlayerId;
  final String toPlayerId;
  const PayScreen({
    super.key,
    required this.fromPlayerId,
    required this.toPlayerId,
    required this.gameId,
  });

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final TextEditingController _amount = TextEditingController();
  String? recipientName;

  @override
  void initState() {
    super.initState();
    _fetchRecipientName(); // Make sure this is called
  }

  Future<void> _fetchRecipientName() async {
    final DatabaseReference playerRef = FirebaseDatabase.instance.ref('games');

    final snapshot = await playerRef.get();
    if (snapshot.exists) {
      final playerData = snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        recipientName =
            playerData?[widget.gameId]['Players'][widget.toPlayerId]['name'];
      });
    } else {
      setState(() {
        recipientName = 'Recipient not found';
      });
    }
  }

  Future<void> _submitPayment() async {
    final String amountText = _amount.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please enter an amount to pay.'),
          duration: Duration(milliseconds: 800),
        ),
      );
      return; // Exit the method if no amount is entered
    }

    final double? amountToPay = double.tryParse(
      amountText,
    ); // Convert text to a number

    if (amountToPay == null || amountToPay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0.'),
        ),
      );
      return; // Exit if the amount is not valid
    }

    final String fromPlayerId = widget.fromPlayerId;

    final DatabaseReference senderRef = FirebaseDatabase.instance.ref('games');

    final snapshot = await senderRef.get();
    if (!snapshot.exists || snapshot.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not retrieve your current balance.'),
        ),
      );
      return;
    }

    final gameData = snapshot.value as Map<dynamic, dynamic>?;

    final playersData =
        gameData?[widget.gameId]?['Players']
            as Map<dynamic, dynamic>?; // Access the Players node
    final currentPlayer =
        playersData?[fromPlayerId]
            as Map<dynamic, dynamic>?; // Access the current player's data
    final currentBalance = currentPlayer?['balance'] ?? 0;

    if (amountToPay > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Insufficient balance.'),
          duration: Duration(milliseconds: 800),
        ),
      );
      return; // Exit if balance is insufficient
    }

    //process payment

    final double newSenderBalance = currentBalance - amountToPay;

    final DatabaseReference receiverRef = FirebaseDatabase.instance.ref(
      'games',
    );

    final receiverSnapshot = await receiverRef.get();
    if (!receiverSnapshot.exists || receiverSnapshot.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not retrieve recipient\'s current balance.'),
        ),
      );
      return;
    }

    final receiverPlayerData = receiverSnapshot.value as Map<dynamic, dynamic>?;
    final currentRecipientBalance =
        receiverPlayerData?[widget.gameId]['Players'][widget
            .toPlayerId]['balance'];

    final double newRecipientBalance = currentRecipientBalance + amountToPay;

    // actual payment

    final DatabaseReference receiverReference = FirebaseDatabase.instance
        .ref('games')
        .child(
          widget.gameId,
        ) // Access the gameId passed from the previous screen
        .child('Players')
        .child(widget.toPlayerId);

    await receiverReference.set({
      'name':
          receiverPlayerData?[widget.gameId]['Players'][widget
              .toPlayerId]['name'],
      'balance': newRecipientBalance,
      'isAdmin':
          receiverPlayerData?[widget.gameId]['Players'][widget
              .toPlayerId]['isAdmin'],
      'bankId':
          receiverPlayerData?[widget.gameId]['Players'][widget
              .toPlayerId]['bankId'],
    });

    //sender balance

    final DatabaseReference senderReference = FirebaseDatabase.instance
        .ref('games')
        .child(
          widget.gameId,
        ) // Access the gameId passed from the previous screen
        .child('Players')
        .child(widget.fromPlayerId);

    await senderReference.set({
      'name': currentPlayer?['name'],
      'balance': newSenderBalance,
      'isAdmin': currentPlayer?['isAdmin'],
      'bankId': currentPlayer?['bankId'],
    });

    // Create Logs here
    final DatabaseReference logReference =
        FirebaseDatabase.instance
            .ref('games')
            .child(widget.gameId)
            .child('Logs')
            .push();

    logReference.set({
      'message':
          '${currentPlayer?['name']} paid ${receiverPlayerData?[widget.gameId]['Players'][widget.toPlayerId]['name']} ${amountToPay.toInt()}',
    });

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Text('Paying $recipientName'),
              // Text(recipientName ?? "Loading name..."),
              TextField(
                controller: _amount,
                autofocus: true,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                // Add this button
                onPressed: () {
                  _submitPayment();
                },
                child: const Text('Confirm Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
