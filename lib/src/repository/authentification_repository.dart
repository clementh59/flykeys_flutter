import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthentificationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User _user;

  //region Sign in / up
  //region Google
  Future<int> signInWithGoogle() async {

    try {

      print("0");

      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      print("0,1");

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      print("0,2");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      print("1");

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User user = authResult.user;

      assert(!user.isAnonymous);
      print("2");

      assert(await user.getIdToken() != null);
      print("3");

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      _user = user;

      print('Everything is ok');
      return 0;
    } catch (e) {
      print('Everyth nnnnnok');
      print(e);
      return -1;
    }
  }
  //endregion

  //region Email/password
  Future<String> handleSignInEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInEmail succeeded: $user');

      _user = user;

      return "OK";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Strings.email_non_valide;
      } else if (e.code == 'wrong-password') {
        return Strings.error_wrong_password;
      }
      return getErrorString(e.code);
    } on PlatformException catch (exception) {
      return getErrorString(exception.code);
    }

		return Strings.la_creation_de_compte_a_echoue;
	}

  Future<String> handleSignUp(email, password, name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final User user = result.user;

      assert(user != null);
      assert(await user.getIdToken() != null);

			_user = user;

			return "OK";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return Strings.mdp_too_short;
      } else if (e.code == 'email-already-in-use') {
        return Strings.account_already_exists;
      }
      return getErrorString(e.code);
    } on PlatformException catch (exception) {
      return getErrorString(exception.code);
    }

    return Strings.la_creation_de_compte_a_echoue;
  }
  //endregion
  //endregion

  //region Disconnection
  Future<void> disconnect() async {
    await FirebaseAuth.instance.signOut();
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
  }
  //endregion

  //region Utils
  // todo: these codes are now invalid ?
  String getErrorString(String code) {
    switch (code) {
      case "ERROR_INVALID_CUSTOM_TOKEN":
        return Strings.ERROR_INVALID_CUSTOM_TOKEN;
      case "ERROR_CUSTOM_TOKEN_MISMATCH":
        return Strings.ERROR_CUSTOM_TOKEN_MISMATCH;
      case "ERROR_INVALID_CREDENTIAL":
        return Strings.ERROR_INVALID_CREDENTIAL;
      case "ERROR_INVALID_EMAIL":
        return Strings.email_non_valide;
      case "ERROR_WRONG_PASSWORD":
        return Strings.error_wrong_password;
      case "ERROR_USER_MISMATCH":
        return Strings.ERROR_USER_MISMATCH;
      case "ERROR_REQUIRES_RECENT_LOGIN":
        return Strings.ERROR_REQUIRES_RECENT_LOGIN;
      case "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL":
        return Strings.ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        return Strings.account_already_exists;
      case "ERROR_CREDENTIAL_ALREADY_IN_USE":
        return Strings.ERROR_CREDENTIAL_ALREADY_IN_USE;
      case "ERROR_USER_DISABLED":
        return Strings.ERROR_USER_DISABLED;
      case "ERROR_USER_TOKEN_EXPIRED":
        return Strings.ERROR_USER_TOKEN_EXPIRED;
      case "ERROR_USER_NOT_FOUND":
        return Strings.ERROR_USER_NOT_FOUND;
      case "ERROR_INVALID_USER_TOKEN":
        return Strings.ERROR_INVALID_USER_TOKEN;
      case "ERROR_OPERATION_NOT_ALLOWED":
        return Strings.ERROR_OPERATION_NOT_ALLOWED;
      case "ERROR_WEAK_PASSWORD":
        return Strings.mdp_too_short;
      default:
        return Strings.la_creation_de_compte_a_echoue;
    }
  }

  Future<void> sendForgotPasswordMail(String mail) async {
    await _auth.sendPasswordResetEmail(email: mail);
  }

  /// [returns] true if the user is logged in - false otherwise
  Future<bool> checkIfHeIsLoggedIn() async {
    User value = FirebaseAuth.instance.currentUser;
    if (value == null)
     return false;
    return true;
  }
  //endregion

}

/*("ERROR_INVALID_CUSTOM_TOKEN", "The custom token format is incorrect. Please check the documentation."));
		("ERROR_CUSTOM_TOKEN_MISMATCH", "The custom token corresponds to a different audience."));
		("ERROR_INVALID_CREDENTIAL", "The supplied auth credential is malformed or has expired."));
		("ERROR_INVALID_EMAIL", "The email address is badly formatted."));
		("ERROR_WRONG_PASSWORD", "The password is invalid or the user does not have a password."));
		("ERROR_USER_MISMATCH", "The supplied credentials do not correspond to the previously signed in user."));
		("ERROR_REQUIRES_RECENT_LOGIN", "This operation is sensitive and requires recent authentication. Log in again before retrying this request."));
		("ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL", "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address."));
		("ERROR_EMAIL_ALREADY_IN_USE", "The email address is already in use by another account."));
		("ERROR_CREDENTIAL_ALREADY_IN_USE", "This credential is already associated with a different user account."));
		("ERROR_USER_DISABLED", "The user account has been disabled by an administrator."));
		("ERROR_USER_TOKEN_EXPIRED", "The user\'s credential is no longer valid. The user must sign in again."));
		("ERROR_USER_NOT_FOUND", "There is no user record corresponding to this identifier. The user may have been deleted."));
		("ERROR_INVALID_USER_TOKEN", "The user\'s credential is no longer valid. The user must sign in again."));
		("ERROR_OPERATION_NOT_ALLOWED", "This operation is not allowed. You must enable this service in the console."));
		("ERROR_WEAK_PASSWORD", "The given password is invalid."));*/
