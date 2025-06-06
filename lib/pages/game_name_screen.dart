import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:monopoly_tracker/pages/mpay_home.dart';

class GameNameScreen extends StatefulWidget {
  const GameNameScreen({super.key});

  @override
  State<GameNameScreen> createState() => _GameNameScreenState();
}

class _GameNameScreenState extends State<GameNameScreen> {
  final TextEditingController _userNameController = TextEditingController();

  Future<void> _createGameAndPlayer() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final String preferredGameName = _userNameController.text.trim();

      if (preferredGameName.isNotEmpty) {
        final String currentPlayerId = currentUser.uid;
        final DatabaseReference gamesRef = FirebaseDatabase.instance.ref(
          'games',
        );
        final DatabaseReference newGameRef = gamesRef.push();
        final String gameId = newGameRef.key!;

        final DatabaseReference bankRef = newGameRef.child('Players').push();
        await bankRef.set({
          'name': 'Bank',
          'balance': 10000000,
          'isAdmin': false,
        });

        // Set the player's preferred name under the Players node of the new game
        await newGameRef.child('Players').child(currentPlayerId).set({
          'name': preferredGameName,
          'balance': 1500,
          'isAdmin': true,
          'bankId': bankRef.key,
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MpayHome(gameId: gameId)),
          );
        }
        // Optionally, you can navigate to the next screen (e.g., a game lobby) here
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your name for the game.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('User not logged in, cannot create game.');
    }
  }

  @override
  void initState() {
    super.initState();
    // Show a snackbar message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game created'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Game')),
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            Text(
              'You will be made the bank',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            TextField(
              autofocus: true,
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'Enter your name'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _createGameAndPlayer();
              },
              child: const Text('Enter Game'),
            ),
          ],
        ),
      ),
    );
  }
}
