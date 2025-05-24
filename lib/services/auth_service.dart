import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // メールアドレス・ユーザー名の重複チェック
  Future<void> _checkEmailAndUsernameUnique({
    required String email,
    required String username,
  }) async {
    // メールアドレスの重複チェック
    final emailQuery =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
    if (emailQuery.docs.isNotEmpty) {
      throw Exception('このメールアドレスは既に使用されています。');
    }

    // ユーザー名の重複チェック
    final usernameQuery =
        await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();
    if (usernameQuery.docs.isNotEmpty) {
      throw Exception('このユーザー名は既に使用されています。');
    }
  }

  // メールサインアップ＋確認メール＋仮保存（pendingUsers）
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 重複チェック
      await _checkEmailAndUsernameUnique(email: email, username: username);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.sendEmailVerification();

      // 仮登録（確認メール送信後に pendingUsers に保存）
      await _firestore
          .collection('pendingUsers')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
            'username': username,
            'createdAt': Timestamp.now(),
          });

      return userCredential;
    } catch (e) {
      throw Exception('新規登録に失敗しました: $e');
    }
  }

  // メール確認後の本登録（users コレクションに登録、pendingUsers を削除）
  Future<void> createUserWithVerifiedEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('ユーザーがログインしていません。');
    }

    await user.reload();
    if (!user.emailVerified) {
      throw Exception('メールアドレスが確認されていません。');
    }

    // pendingUsers から username を取得
    final pendingSnapshot =
        await _firestore.collection('pendingUsers').doc(user.uid).get();
    if (!pendingSnapshot.exists) {
      throw Exception('一時ユーザー情報が存在しません。');
    }

    final data = pendingSnapshot.data()!;
    final username = data['username'] as String? ?? '';

    // 本登録
    await user.updateDisplayName(username);
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'username': username,
      'createdAt': Timestamp.now(),
    });

    // pendingUsers から削除
    await _firestore.collection('pendingUsers').doc(user.uid).delete();
  }

  // メールログイン
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('ログイン失敗: $e');
    }
  }

  // メール確認済みかチェック
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  // Googleログイン
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Googleサインインがキャンセルされました');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Firestore にユーザーがいなければ保存（初回ログイン時）
      final doc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'username': userCredential.user!.displayName ?? '',
          'createdAt': Timestamp.now(),
        });
      }

      return userCredential;
    } catch (e) {
      throw Exception('Googleログイン失敗: $e');
    }
  }
}
