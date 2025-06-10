import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/bloc/auth/bloc.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/pages/home_page.dart';
import 'package:smart_home_app/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('LOGIN_PAGE: Build method called.');
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('LOGIN_PAGE_LISTENER: State is ${state.runtimeType}');
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        },
        builder: (context, state) {
          print('LOGIN_PAGE_BUILDER: State is ${state.runtimeType}');

          if(state is AuthFailure){
            print(state.error);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  key: const ValueKey('email_field'),
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  key: const ValueKey('password_field'),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (state is AuthLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            LoginRequested(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                    },
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Register',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 