import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpScreen();
}


class _SignUpScreen extends State<SignUpScreen> {

  // TODO: Deklarasi variable;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";
  bool _isSignin = false;
  bool _obsecurePassword = false;

  //TODO 1. membuat fungsi _signUp
  void _signUp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Validasi password
    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) || // Tidak mengandung huruf besar
        !password.contains(RegExp(r'[a-z]')) || // Tidak mengandung huruf kecil
        !password.contains(RegExp(r'[0-9]')) || // Tidak mengandung angka
        !password.contains(RegExp(r'[@#$%^&*(),.?":{}|<>]'))) {
      // Tidak mengandung karakter khusus
      setState(() {
        _errorMessage =
        "Password harus minimal 8 karakter, mengandung huruf besar, huruf kecil, angka, dan karakter khusus";
      });
      return; // Hentikan proses jika password tidak valid
    }

    // Reset error jika password valid
    setState(() {
      _errorMessage = "";
    });

    // Simpan data terenkripsi jika valid
    if (name.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      final encrypt.Key key = encrypt.Key.fromLength(32);
      final iv = encrypt.IV.fromLength(16);

      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encryptedName = encrypter.encrypt(name, iv: iv);
      final encryptedUsername = encrypter.encrypt(username, iv: iv);
      final encryptedPassword = encrypter.encrypt(password, iv: iv);

      // Simpan data pengguna di SharedPreferences
      prefs.setString('fullname', encryptedName.base64);
      prefs.setString('username', encryptedUsername.base64);
      prefs.setString('password', encryptedPassword.base64);
      prefs.setString('key', key.base64);
      prefs.setString('iv', iv.base64);

      // Navigasi ke halaman signin
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: Pasang AppBar;
      appBar: AppBar(
        title: const Text("Sign in"),
        automaticallyImplyLeading: false,
      ),
      // TODO: Pasang Body;
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // TODO: Atur mainAxisAlignment dan CrossAxisAlignment;
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TODO: Nama lengkap;
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: "Nama",
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                // TODO: Pasang TextFormField Nama pengguna;
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                      labelText: "Nama pengguna",
                      border: OutlineInputBorder()
                  ),
                ),

                // TODO: Pasang TextFormField Kata sandi;
                SizedBox(height: 20,),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        _obsecurePassword = !_obsecurePassword;
                      });
                    }, icon: Icon(_obsecurePassword ? Icons.visibility_off : Icons.visibility)),
                  ),
                  obscureText: _obsecurePassword,
                ),
                // TODO: Pasang ElevatedButton Sign in;
                SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: () {_signUp();},
                    child: const Text('Sign In')
                ),
                // ElevatedButton(
                //   onPressed: (){},
                //   child: Text("Login"),
                // ),
                SizedBox(height: 20,),
                RichText(text: TextSpan(
                    text: "Sudah punya akun? ",
                    style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                    children: <TextSpan>[
                      TextSpan(
                        text: "login!",
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = (){ Navigator.pushNamed(context, "/signin");},
                      )
                    ]
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}