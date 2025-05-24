import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:monopoly_tracker/pages/mpay_home.dart';

class NonAdminNameScreen extends StatefulWidget {
  final String gameId;
  const NonAdminNameScreen({super.key, required this.gameId});

  @override
  State<NonAdminNameScreen> createState() => _NonAdminNameScreenState();
}

class _NonAdminNameScreenState extends State<NonAdminNameScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _joinGame() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final String playerName = _nameController.text.trim();
      final String playerId = currentUser.uid;
      final DatabaseReference gamePlayersRef = FirebaseDatabase.instance
          .ref('games')
          .child(
            widget.gameId,
          ) // Access the gameId passed from the previous screen
          .child('Players');

      if (playerName.isNotEmpty) {
        await gamePlayersRef.child(playerId).set({
          'name': playerName,
          'balance': 1500,
          'isAdmin': false,
        });
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MpayHome(gameId: widget.gameId),
            ),
          );
        }
        // Optionally navigate to the game screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your name to join the game.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('User not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Non Admins enter game')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(50),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Your Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _joinGame();
              },
              child: Text('Enter Game'),
            ),
          ],
        ),
      ),
    );
  }
}
