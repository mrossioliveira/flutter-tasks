import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks/providers/auth.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: SignupCard(),
            ),
          ),
        ),
      ),
    );
  }
}

class SignupCard extends StatefulWidget {
  @override
  _SignupCardState createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  final _formkey = new GlobalKey<FormState>();

  bool _isLoading;

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
                    'Sign up!',
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
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'email',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Email required';
                      } else {
                        return null;
                      }
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
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
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
                                Icons.check,
                                color: Colors.grey[200],
                              ),
                      ),
                      onPressed: () async {
                        if (_formkey.currentState.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await Provider.of<Auth>(context, listen: false)
                                .signIn(
                              'mrossioliveira',
                              'slip0423',
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          } catch (e) {
                            print(e);
                            setState(() {
                              _isLoading = false;
                            });
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
            "Already have an account?",
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
              Navigator.of(context).pop();
            },
            child: Text(
              'Sign in',
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
