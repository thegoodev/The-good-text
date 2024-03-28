import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Login extends StatefulWidget{
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _busy = false;
  String? _emailError, _passwordError;

  TextEditingController _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  void login() async {

    setState(() {
      _busy = true;
      _emailError = null;
      _passwordError = null;
    });

    try{
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print(credential.user);

      context.go("/");
    }on FirebaseAuthException catch (e){
      setState(() {
       _busy = false;
      });

      switch(e.code){
        case "invalid-email":
        case "user-not-found":
        case "user-disabled":
          setState(() {
            _emailError = e.message;
          });
          break;
        case "wrong-password":
          setState(() {
            _passwordError = e.message;
          });
          break;
        default:
          print("Code: ${e.code}, Message: ${e.message}");
          break;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Image.asset("assets/clouds.png"),
          ),
          SafeArea(
            child: Center(
              child:SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child:  Image.asset("images/logo.png", height: 48),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Ingresa tus datos para ',
                          children: const <TextSpan>[
                            TextSpan(
                              text: 'Iniciar Sesión',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      EmailTextField(
                        error: _emailError,
                        controller: _emailController,
                      ),
                      SizedBox(height: 24),
                      PasswordTextField(
                        error: _passwordError,
                        controller: _passwordController,
                      ),
                      SizedBox(height: 12.0),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: _busy? null :login,
                          child: Text(_busy?"LOADING...":"LOGIN"),
                        ),
                      )
                    ],
                  ),
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmailTextField extends StatelessWidget{

  EmailTextField({
    this.error,
    required this.controller,
  });

  final String? error;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: [
        AutofillHints.email,
      ],
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        errorText: error,
        labelText: "Email",
        prefixIcon: Icon(Icons.alternate_email_outlined),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget{
  PasswordTextField({
    this.error,
    required this.controller,
  });

  final String? error;
  final TextEditingController controller;

  @override
  State<StatefulWidget> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField>{

  bool obscureText = true;

  toggleObscureText(){
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      autofillHints: [
        AutofillHints.password,
      ],
      controller: widget.controller,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        filled: true,
        errorText: widget.error,
        labelText: "Password",
        prefixIcon: Icon(Icons.lock_outline),
        suffix: GestureDetector(
          child: Icon(
              obscureText ?
              Icons.visibility_outlined :
              Icons.visibility_off_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: toggleObscureText,
        )
      ),
    );
  }
}