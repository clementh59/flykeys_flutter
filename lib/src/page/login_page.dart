import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/authentification/authentification_bloc.dart';
import 'package:flykeys/src/bloc/authentification/authentification_event.dart';
import 'package:flykeys/src/bloc/authentification/authentification_state.dart';
import 'package:flykeys/src/page/main_page.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/strings.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //region Variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AuthentificationBloc authentificationBloc;

  String view = "login";
  String passwordInput = "";
  String mailInput = "";
  String nameInput = "";
  String confirmPasswordInput = "";

  String errorEmail = "";
  String errorName = "";
  String errorPassword = "";
  String errorConfirmPassword = "";

  TextEditingController _textEditingControllerMail =
  TextEditingController(text: "");
  TextEditingController _textEditingControllerFullName =
  TextEditingController();
  TextEditingController _textEditingControllerPassword =
  TextEditingController(text: "");

  bool im_waiting = false;
  //endregion

  //region Overrides
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authentificationBloc = BlocProvider.of<AuthentificationBloc>(context);
    authentificationBloc.add(CheckIfHeIsLogin());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: authentificationBloc,
      listener: (BuildContext context, state) {
        if (state is AuthentificateFailedState) {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text(state.result)));
        }
        setState(() {
          im_waiting = false;
        });
      },
      child: BlocBuilder<AuthentificationBloc, AuthentificationState>(
          bloc: authentificationBloc,
          builder: (BuildContext context, AuthentificationState state) {
            if (state is AuthentificateSucceedState)
              return MainPage();

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: CustomColors.backgroundColor,
              body: SafeArea(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                    child: view == "login"
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Sign In',
                          style: CustomStyle.signInLoginPage,
                        ),
                        _buildEmailTF(),
                        _buildPasswordTF(true),
                        _buildLoginBtn(),
                        _buildSignInWithText(),
                        _buildSignupBtn(),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Sign Up',
                          style: CustomStyle.signInLoginPage,
                        ),
                        _buildNameTF(),
                        _buildEmailTF(),
                        _buildPasswordTF(false),
                        _buildConfirmPasswordTF(),
                        _buildRegisterBtn(),
                        _buildSigninBtn(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
  //endregion

  //region Widgets
  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: CustomStyle.labelLoginPage,
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: CustomStyle.boxDecorationStyleLoginPage,
          height: 50.0,
          child: TextField(
            controller: _textEditingControllerMail,
            keyboardType: TextInputType.emailAddress,
            onChanged: (text) {
              mailInput = text;
            },
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.mail_outline,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle: CustomStyle.hintTextLoginPage,
            ),
          ),
        ),
        SizedBox(height: 5.0),
        errorEmail != "" ? _errorText(errorEmail) : SizedBox(),
      ],
    );
  }

  Widget _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Full Name',
          style: CustomStyle.labelLoginPage,
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: CustomStyle.boxDecorationStyleLoginPage,
          height: 50.0,
          child: TextField(
            controller: _textEditingControllerFullName,
            keyboardType: TextInputType.emailAddress,
            onChanged: (text) {
              nameInput = text;
            },
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
              hintText: 'Enter your Name',
              hintStyle: CustomStyle.hintTextLoginPage,
            ),
          ),
        ),
        SizedBox(height: 5.0),
        errorName != "" ? _errorText(errorName) : SizedBox(),
      ],
    );
  }

  Widget _buildPasswordTF(bool showForgotText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: CustomStyle.labelLoginPage,
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: CustomStyle.boxDecorationStyleLoginPage,
          height: 50.0,
          child: TextField(
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            controller: _textEditingControllerPassword,
            onChanged: (text) {
              passwordInput = text;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: CustomStyle.hintTextLoginPage,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Stack(
            children: [
              errorPassword != ""
                ? Align(
                alignment: Alignment.centerLeft,
                child: _errorText(errorPassword))
                : SizedBox(),
              showForgotText
                ? Align(
                alignment: Alignment.centerRight,
                child: _buildForgotPasswordBtn())
                : SizedBox(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildConfirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Confirm Password',
          style: CustomStyle.labelLoginPage,
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: CustomStyle.boxDecorationStyleLoginPage,
          height: 50.0,
          child: TextField(
            obscureText: true,
            onChanged: (text) {
              confirmPasswordInput = text;
            },
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.white,
              ),
              hintText: 'Confirm your Password',
              hintStyle: CustomStyle.hintTextLoginPage,
            ),
          ),
        ),
        errorConfirmPassword != ""
          ? _errorText(errorConfirmPassword)
          : SizedBox(),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () => _showDialog(),
        child: Text(
          'Forgot Password?',
          style: CustomStyle.labelLoginPage,
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => login(),
        padding: EdgeInsets.all(13.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: im_waiting
          ? CircularProgressIndicator(
          valueColor:
          new AlwaysStoppedAnimation<Color>(CustomColors.blue),
        )
          : Text('LOGIN', style: CustomStyle.loginButtonLoginPage),
      ),
    );
  }

  Widget _buildRegisterBtn() {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => register(),
        padding: EdgeInsets.all(13.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: im_waiting
          ? CircularProgressIndicator(
          valueColor:
          new AlwaysStoppedAnimation<Color>(CustomColors.blue),
        )
          : Text('REGISTER', style: CustomStyle.loginButtonLoginPage),
      ),
    );
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins'),
        ),
        SizedBox(height: 15.0),
        Text(
          'Sign in with',
          style: CustomStyle.labelLoginPage,
        ),
        SizedBox(height: 15.0),
        _buildSocialBtnRow(),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildSocialBtn(
            () => loginWithGoogle(),
          AssetImage(
            'assets/images/icons/google.jpg',
          ),
        ),
      ],
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => goToSignUp(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins'),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSigninBtn() {
    return GestureDetector(
      onTap: () => goToLoginPage(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins'),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorText(String text) {
    return Text(
      text,
      style: CustomStyle.errorLoginPage,
    );
  }
  //endregion

  //region Logic
  void register() {
    bool signup = true;

    if (!EmailValidator.validate(mailInput)) {
      setState(() {
        errorEmail = Strings.email_non_valide;
      });
      signup = false;
    } else {
      setState(() {
        errorEmail = "";
      });
    }

    if (passwordInput.length < 6) {
      setState(() {
        errorPassword = Strings.mdp_too_short;
      });
      signup = false;
    } else {
      setState(() {
        errorPassword = "";
      });
    }

    if (signup) {
      setState(() {
        im_waiting = true;
      });
      authentificationBloc..add(SignUp(mailInput, passwordInput, nameInput));
    }
  }

  void login() {
    bool login = true;

    if (!EmailValidator.validate(mailInput)) {
      setState(() {
        errorEmail = Strings.email_non_valide;
      });
      login = false;
    } else {
      setState(() {
        errorEmail = "";
      });
    }

    if (passwordInput.length == 0) {
      setState(() {
        errorPassword = Strings.mdp_peut_pas_etre_vide;
      });
      login = false;
    } else {
      setState(() {
        errorPassword = "";
      });
    }

    if (login) {
      setState(() {
        im_waiting = true;
      });
      authentificationBloc..add(AuthentificateByMail(mailInput, passwordInput));
    }
  }

  void loginWithGoogle() {
    setState(() {
      im_waiting = true;
    });
    authentificationBloc..add(AuthentificateWithGoogle());
  }

  void forgotPassword(String mail) {
    authentificationBloc..add(ForgotPassword(mail));
  }

  void _showDialog() {
    // flutter defined function

    String mail = _textEditingControllerMail.text;

    if (!EmailValidator.validate(mail)) {
      setState(() {
        errorEmail = Strings.entre_ton_email_pour_reinitialiser;
      });
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Forgot password"),
          content: new Text(
              "Un mail va être envoyé à $mail, est ce bien vôtre adresse?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Non"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Oui"),
              onPressed: () {
                forgotPassword(mail);
                Navigator.of(context).pop();
                _scaffoldKey.currentState.showSnackBar(
                    SnackBar(content: Text(Strings.email_envoye)));
              },
            ),
          ],
        );
      },
    );
  }

  void goToSignUp() {
    _textEditingControllerFullName.text = "";
    _textEditingControllerMail.text = mailInput;
    _textEditingControllerPassword.text = passwordInput;
    setState(() {
      errorEmail = "";
      errorName = "";
      errorPassword = "";
      errorConfirmPassword = "";
      view = "signup";
    });
  }

  void goToLoginPage() {
    _textEditingControllerFullName.text = "";
    _textEditingControllerMail.text = mailInput;
    _textEditingControllerPassword.text = passwordInput;
    setState(() {
      errorEmail = "";
      errorName = "";
      errorPassword = "";
      errorConfirmPassword = "";
      view = "login";
    });
  }
//endregion
}
