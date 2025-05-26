import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:monopoly_tracker/pages/game_name_screen.dart';
import 'package:monopoly_tracker/pages/mpay_home.dart';
import 'package:monopoly_tracker/pages/non_admin_name_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  @override
  void initState() {
    super.initState();
    // Show a snackbar message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully Signed In'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create or join a Game')),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameNameScreen(),
                      ),
                    );
                  }
                },
                child: Text('Create Game'),
              ),
              SizedBox(height: 50),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance.ref('games').onValue,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<DatabaseEvent> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      // Check if we have data
                      final gamesData =
                          snapshot.data!.snapshot.value
                              as Map<
                                dynamic,
                                dynamic
                              >?; // Extract the data as a Map

                      if (gamesData == null || gamesData.isEmpty) {
                        return const Center(
                          child: Text('No games available yet.'),
                        ); // Handle the case with no games
                      } else {
                        final gameIds = gamesData.keys.toList();

                        return ListView.builder(
                          itemCount: gameIds.length,
                          itemBuilder: (context, index) {
                            final gameId = gameIds[index];
                            return InkWell(
                              onTap: () async {
                                if (mounted) {
                                  final String? currentUserId =
                                      FirebaseAuth.instance.currentUser?.uid;

                                  if (currentUserId != null) {
                                    final DatabaseReference gamesRef =
                                        FirebaseDatabase.instance.ref('games');

                                    final snapshot = await gamesRef.get();

                                    final value =
                                        snapshot.value
                                            as Map<
                                              dynamic,
                                              dynamic
                                            >?; // Cast to your expected type

                                    if (value?[gameId]['Players'][currentUserId] !=
                                        null) {
                                      // User is already in the game, navigate to the other screen
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => /* Your Other Screen Widget */
                                                    MpayHome(gameId: gameId),
                                          ),
                                        );
                                      }
                                    } else {
                                      // User is not in the game, navigate to NonAdminNameScreen
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => NonAdminNameScreen(
                                                  gameId: gameId,
                                                ),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    // Handle the case where the user is not logged in
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You must be logged in to join a game.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Card(
                                margin: const EdgeInsets.all(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text('Game ID: $gameId'),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading games: ${snapshot.error}'),
                      ); // Handle errors
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      ); // Show loading indicator while waiting for data
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
