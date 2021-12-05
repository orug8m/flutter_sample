import 'package:flutter/material.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // アプリ名
      title: 'Sample Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Login'),
              onPressed: () async {
                // チャット画面に遷移＋ログイン画面を破棄
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return ChatPage();
                  }),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              // ログイン画面に遷移＋チャット画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddPostPage();
            }),
          );
        },
      ),
    );
  }
}


// 投稿画面用Widget
class AddPostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Chat'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Back'),
          onPressed: () {
            // 1つ前の画面に戻る
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
