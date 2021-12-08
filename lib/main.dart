import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ユーザー情報の受け渡しを行うためのProvider
final userProvider = StateProvider((ref) {
  return FirebaseAuth.instance.currentUser;
});

// エラー情報の受け渡しを行うためのProvider
// ※ autoDisposeを付けることで自動的に値をリセットできます
final infoTextProvider = StateProvider.autoDispose((ref) {
  return '';
});

// メールアドレスの受け渡しを行うためのProvider
// ※ autoDisposeを付けることで自動的に値をリセットできます
final emailProvider = StateProvider((ref) {
  return '';
});

// パスワードの受け渡しを行うためのProvider
// ※ autoDisposeを付けることで自動的に値をリセットできます
final passwordProvider = StateProvider.autoDispose((ref) {
  return '';
});

// メッセージの受け渡しを行うためのProvider
// ※ autoDisposeを付けることで自動的に値をリセットできます
final messageTextProvider = StateProvider.autoDispose((ref) {
  return '';
});

// StreamProviderを使うことでStreamも扱うことができる
// ※ autoDisposeを付けることで自動的に値をリセットできます
final postsQueryProvider = StreamProvider.autoDispose((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .orderBy('date')
      .snapshots();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(ProviderScope(child: ChatApp()));
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

// ログイン画面用Widget
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから値を受け取る
    User? user = ref.watch(userProvider);
    String infoText = ref.watch(infoTextProvider);
    String email = ref.watch(emailProvider);
    String password = ref.watch(passwordProvider);

    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // メールアドレス入力
              TextFormField(
                decoration: const InputDecoration(labelText: 'mail'),
                onChanged: (String value) {
                  // Providerから値を更新
                  email = value;
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: const InputDecoration(labelText: 'password'),
                obscureText: true,
                onChanged: (String value) {
                  password = value;
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),
              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: ElevatedButton(
                  child: const Text('Resister'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ユーザー情報を更新
                      user = result.user;
                      // ユーザー登録に成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return ChatPage();
                        }),
                      );
                    } catch (e) {
                      // ユーザー登録に失敗した場合
                      // Providerから値を更新
                      infoText = "登録に失敗しました：${e.toString()}";
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                // ログインボタン
                child: OutlinedButton(
                  child: const Text('Login'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ユーザー情報を更新
                      user = result.user;
                      // ログインに成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return ChatPage();
                        }),
                      );
                    } catch (e) {
                      // ログインに失敗した場合
                      infoText = "ログインに失敗しました：${e.toString()}";
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

// チャット画面用Widget
class ChatPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ユーザー情報を受取る
    final User user = ref.watch(userProvider)!;
    final AsyncValue<QuerySnapshot> asyncPostsQuery =
        ref.watch(postsQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // ログアウト処理
              // 内部で保持しているログイン情報等が初期化される
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移+チャット画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Column(
        // ユーザー情報を表示
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Text('hello ${user.email}'),
          ),
          Expanded(
            // StreamBuilder
            // 非同期処理の結果を元にWidgetを作る
            child: asyncPostsQuery.when(
              data: (QuerySnapshot query) {
                // 取得した投稿メッセージ一覧を元にリスト表示
                return ListView(
                  children: query.docs.map((document) {
                    return Card(
                      child: ListTile(
                        title: Text(document['text']),
                        subtitle: Text(document['email']),
                        // 自分の投稿メッセージの場合は削除ボタンを表示
                        trailing: document['email'] == user.email
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  // 投稿メッセージのドキュメントを削除
                                  await FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(document.id)
                                      .delete();
                                },
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () {
                return const Center(
                  child: Text('loading...'),
                );
              },
              error: (e, stackTrace) {
                return Center(
                  child: Text(e.toString()),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
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
class AddPostPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ユーザー情報を受け取る
    final User user = ref.watch(userProvider)!;
    String messageText = ref.watch(messageTextProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Chat'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 投稿メッセージ入力
              TextFormField(
                decoration: const InputDecoration(labelText: 'send message'),
                //複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                //最大3行
                maxLines: 3,
                onChanged: (String value) {
                  messageText = value;
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Post　'),
                  onPressed: () async {
                    final date = DateTime.now().toLocal().toIso8601String();
                    final email = user.email;
                    //投稿メッセージ用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc()
                        .set({
                      'text': messageText,
                      'email': email,
                      'date': date
                    });
                    // 1つ前の画面に戻る
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
