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
    final DatabaseReference playerRef = FirebaseDatabase.instance
        .ref('games')
        .child(widget.gameId)
        .child('Players')
        .child(widget.toPlayerId);

    final snapshot = await playerRef.get();
    if (snapshot.exists) {
      final playerData = snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        recipientName =
            playerData?[widget.gameId]['Players'][widget.toPlayerId]['name'];
      });
      print(recipientName);
    } else {
      setState(() {
        recipientName = 'Recipient not found';
      });
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
                  // _submitPayment();
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
