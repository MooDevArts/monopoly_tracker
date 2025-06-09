import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:monopoly_tracker/pages/pay_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class BankScreen extends StatefulWidget {
  final String gameId;
  final String bankId;

  const BankScreen({super.key, required this.gameId, required this.bankId});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  String? currentUserId = '';
  Map<dynamic, dynamic>? userData;
  String? bankId;

  // set init method to assign userdata
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    currentUserId = widget.bankId;
    final DatabaseReference userRef = FirebaseDatabase.instance.ref('games');

    final snapshot = await userRef.get();
    userData = snapshot.value as Map<dynamic, dynamic>?;
    final realUserData = userData?[widget.gameId]['Players'][currentUserId];

    setState(() {
      userData = realUserData;
    });
  }

  void isAdmin() async {
    if (userData?['isAdmin'] == true) {
      print(userData?['bankId']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
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
                            playerData['name'] ??
                            'No Name'; // Modified this line
                        final playerBalance =
                            (playerData['balance'] as num)
                                .toInt(); // Modified this line

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
                                  ' ${playerBalance}',
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
                        child: Text(
                          'Loading your details...',
                        ), // Added this line
                      );
                    }
                    return const SizedBox.shrink(); // Fallback if data is null - Added this line
                  },
                ),
              SizedBox(height: 20),
              Text('Pay Other Players'),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream:
                      FirebaseDatabase.instance
                          .ref('games')
                          .child(widget.gameId)
                          .child('Players')
                          .onValue,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<DatabaseEvent> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      final playersData =
                          snapshot.data!.snapshot.value
                              as Map<dynamic, dynamic>?;
                      if (playersData == null || playersData.isEmpty) {
                        return const Center(
                          child: Text('No other players in this game yet.'),
                        );
                      }

                      final currentPlayerId = widget.bankId;
                      final otherPlayerIds =
                          playersData.keys
                              .where((playerId) => playerId != currentPlayerId)
                              .toList();

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                            ),
                        itemCount: otherPlayerIds.length,
                        itemBuilder: (context, index) {
                          final playerId = otherPlayerIds[index];
                          final player =
                              playersData[playerId] as Map<dynamic, dynamic>?;
                          final playerName = player?['name'] ?? 'No Name';

                          return InkWell(
                            onTap: () async {
                              if (mounted) {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PayScreen(
                                          gameId: widget.gameId,
                                          fromPlayerId: currentPlayerId,
                                          toPlayerId: playerId,
                                        ),
                                  ),
                                );
                                if (result == true) {
                                  //play sound
                                  final player = AudioPlayer();
                                  await player.play(
                                    AssetSource('pay-sound.mp3'),
                                  );
                                  // Check if the result is true (payment was done)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(milliseconds: 800),
                                      backgroundColor: Colors.green,
                                      content: Text('Payment Successful'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  playerName,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading players: ${snapshot.error}'),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(height: 10),

              // Show logs here
              SizedBox(height: 50),
            ],
          ),
        ),
        floatingActionButton:
            userData?['isAdmin'] == true
                ? FloatingActionButton(
                  onPressed: () {
                    isAdmin();
                  },
                  child: Icon(Icons.account_balance_outlined),
                )
                : null,
      ),
    );
  }
}
