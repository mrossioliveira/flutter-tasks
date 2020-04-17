import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks/pages/signup.dart';
import 'package:tasks/providers/auth.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: AuthCard(),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _formkey = new GlobalKey<FormState>();
  String _username;
  String _password;

  bool _isLoading;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          color: Colors.grey[850],
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '.tasks',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w200,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'username',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Username required';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (String value) {
                      _username = value;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'password',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'password required';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (String value) {
                      _password = value;
                    },
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  _error.length > 0 ? Text(_error) : Text(''),
                  SizedBox(
                    width: double.infinity,
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      highlightElevation: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: _isLoading
                            ? CircularProgressIndicator(
                                backgroundColor: Theme.of(context).primaryColor,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward,
                                color: Colors.grey[200],
                              ),
                      ),
                      onPressed: () async {
                        if (_formkey.currentState.validate()) {
                          _formkey.currentState.save();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await Provider.of<Auth>(
                              context,
                              listen: false,
                            ).signIn(
                              _username.trim(),
                              _password.trim(),
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });

                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.message != null
                                      ? e.message
                                      : 'Unable to contact servers.',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Don't have an account?",
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: RaisedButton(
            color: Colors.grey[850],
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SignupPage(),
                ),
              );
            },
            child: Text(
              'Sign up!',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
