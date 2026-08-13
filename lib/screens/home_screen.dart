import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'status_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    ChatListScreen(),
    StatusScreen(),
    Center(child: Text('المكالمات')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تواصل'),
        backgroundColor: Color(0xFF075E54),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'المحادثات'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'الحالات'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'المكالمات'),
        ],
        selectedItemColor: Color(0xFF075E54),
      ),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        var chats = snapshot.data!.docs;
        if (chats.isEmpty) return Center(child: Text('لا توجد محادثات'));
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            var chat = chats[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFF075E54),
                child: Text(chat['otherUserName'][0], style: TextStyle(color: Colors.white)),
              ),
              title: Text(chat['otherUserName']),
              subtitle: Text(chat['lastMessage'] ?? ''),
              trailing: Text(chat['lastMessageTime']?.toDate().toString() ?? ''),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(
                  userId: chat['otherUserId'],
                  username: chat['otherUserName'],
                )),
              ),
            );
          },
        );
      },
    );
  }
}
