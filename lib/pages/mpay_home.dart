import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MpayHome extends StatefulWidget {
  final String gameId;

  const MpayHome({super.key, required this.gameId});

  @override
  State<MpayHome> createState() => _MpayHomeState();
}

class _MpayHomeState extends State<MpayHome> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mpay Home')),
      body: Center(
        child: Column(
          children: [
            if (currentUserId !=
                null) // Ensured user is logged in - Added this condition
              StreamBuilder(
                // Added this widget
                stream:
                    FirebaseDatabase.instance
                        .ref('games')
                        .child(widget.gameId)
                        .child('Players')
                        .child(
                          currentUserId!,
                        ) // Targeting the specific player - Added this line
                        .onValue,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<DatabaseEvent> snapshot,
                ) {
                  if (snapshot.hasData) {
                    final playerData =
                        snapshot.data!.snapshot.value
                            as Map<dynamic, dynamic>?; // Modified this line
                    if (playerData != null) {
                      final playerName =
                          playerData['name'] ?? 'No Name'; // Modified this line
                      final playerBalance =
                          playerData['balance'] ?? '0'; // Modified this line

                      return Card(
                        // Added this widget
                        margin: const EdgeInsets.all(16.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 40,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '$playerName',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text('Your MPay Balance'),
                              Text(
                                '$playerBalance',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ), // Modified this line
                            ],
                          ),
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Padding(
                      // Added this widget
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading your details: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ), // Added this line
                    );
                  } else {
                    return const Padding(
                      // Added this widget
                      padding: EdgeInsets.all(16.0),
                      child: Text('Loading your details...'), // Added this line
                    );
                  }
                  return const SizedBox.shrink(); // Fallback if data is null - Added this line
                },
              ),
            SizedBox(height: 20),
            Text('Pay Other Players'),
          ],
        ),
      ),
    );
  }
}
