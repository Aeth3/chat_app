import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<AuthScreen> {
  late UserCredential userCredentials;
  final _form = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  bool _isAuthenticating = false;
  var _isLogin = true;

  @override
  void dispose() {
    if (mounted) {
      super.dispose();
    }
  }

  void _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final isValid = _form.currentState!.validate();
    try {
      if (!isValid) {
        return;
      }
      setState(() {
        _isAuthenticating = true;
      });
      _form.currentState!.save();

      if (_isLogin) {
        userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      }

      // final storageRef = FirebaseStorage.instance.ref().child('user_images').child('${userCredentials.user!.uid}.png');
      // await storageRef.putFile(_selectedImage!);
      // final imageUrl = await storageRef.getDownloadURL();

      setState(() {
        _isAuthenticating = false;
      });
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      messenger.clearSnackBars();
      messenger.showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/fakebook.png'),
              ),
              Stack(
                children: [
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                            key: _form,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  onSaved: (newValue) {
                                    _enteredEmail = newValue!;
                                  },
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !value.contains('@')) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      label: Text('Email address')),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                ),
                                TextFormField(
                                  onSaved: (newValue) {
                                    _enteredPassword = newValue!;
                                  },
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 6) {
                                      return 'Password must be at least 6 characters long';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      label: Text('Password')),
                                  obscureText: true,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer),
                                    onPressed:
                                        _isAuthenticating ? null : _submit,
                                    child:
                                        Text(_isLogin ? 'Log in' : 'Sign Up')),
                                TextButton(
                                    onPressed: _isAuthenticating
                                        ? null
                                        : () {
                                            setState(() {
                                              _isLogin = !_isLogin;
                                            });
                                          },
                                    child: Text(_isLogin
                                        ? 'Create an Account'
                                        : 'I already have an account'))
                              ],
                            )),
                      ),
                    ),
                  ),
                  if (_isAuthenticating)
                    Container(
                        padding: const EdgeInsets.only(top: 120),
                        child: const Center(child: CircularProgressIndicator()))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
