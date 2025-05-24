
import 'package:chatty_app/Components/user_tile.dart';
import 'package:chatty_app/Pages/chat_page.dart';
import 'package:chatty_app/services/auth/auth_service.dart';
import 'package:chatty_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import '../Components/my_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

void logout (){
  final auth = AuthService();
  auth.signOut();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout))
        ],
      ), 
      drawer: const MyDrawer(),
      body: _buildUserList(),
    ); 
  }
  Widget _buildUserList(){
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError){
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Text("Loading..");
        }
        return ListView(
          children: snapshot.data!
            .map<Widget>((UserData)=> _buildUserListItem(UserData, context))
            .toList(),
        );
      },
    );
  }
  Widget _buildUserListItem(Map<String, dynamic> UserData, BuildContext context){
    if (UserData["email"] != _authService.getCurentUser()!.email){
      return UserTile(
      text: UserData["Email"],
      onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatPage(
            receiverEmail: UserData["Email"],
            receiverID: UserData["uid"],
            ),
          ),
        );
      },
    );
    } else {
      return Container();
    }
  }
}
