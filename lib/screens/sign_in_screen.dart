import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInScreen();
}


class _SignInScreen extends State<SignInScreen> {

  // TODO: Deklarasi variable;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";
  bool _isSignin = false;
  bool _obsecurePassword = false;
  Future<Map<String, String>> _retrieveAndDecryptDataFromPrefs(
      Future<SharedPreferences> prefs,
      ) async {
    final sharedPreferences = await prefs;

    // Ambil data dari SharedPreferences
    final encryptedUsername = sharedPreferences.getString('username') ?? '';
    final encryptedPassword = sharedPreferences.getString('password') ?? '';
    final keyString = sharedPreferences.getString('key') ?? '';
    final ivString = sharedPreferences.getString('iv') ?? '';

    // Validasi jika ada data yang kosong
    if (encryptedUsername.isEmpty ||
        encryptedPassword.isEmpty ||
        keyString.isEmpty ||
        ivString.isEmpty) {
      print('Stored credentials are invalid or incomplete');
      return {};
    }

    // Dekripsi data
    final encrypt.Key key = encrypt.Key.fromBase64(keyString);
    final iv = encrypt.IV.fromBase64(ivString);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decryptedUsername = encrypter.decrypt64(encryptedUsername, iv: iv);
    final decryptedPassword = encrypter.decrypt64(encryptedPassword, iv: iv);

    print('Decrypted Username: $decryptedUsername');
    print('Decrypted Password: $decryptedPassword');

    // Mengembalikan data terdeskripsi
    return {'username': decryptedUsername, 'password': decryptedPassword};
  }


  void _signIn() async {
    try {
      final Future<SharedPreferences> prefsFuture =
      SharedPreferences.getInstance();

      final String username = _usernameController.text.toLowerCase();
      final String password = _passwordController.text;
      print('Sign in attempt');

      if (username.isNotEmpty && password.isNotEmpty) {
        final SharedPreferences prefs = await prefsFuture;
        final data = await _retrieveAndDecryptDataFromPrefs(prefsFuture);
        if (data.isNotEmpty) {
          final decryptedUsername = data['username'];
          final decryptedPassword = data['password'];

          if (username == decryptedUsername?.toLowerCase() && password == decryptedPassword) {
            _errorMessage = '';
            _isSignin = true;
            prefs.setBool('isSignedIn', true);
            //Pemanggilan untuk menghapus semua halaman dalam tumpukan navigasi
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
            //Sign in berhasil, navigasi ke layar utama
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/home');
            });
            print("Sign in succeeded");
          } else {
            print('Username or password is incorrect: ${username} == ${decryptedUsername} || ${password} == ${decryptedPassword}');
          }
        } else {
          print('No stored credentials found');
        }
      } else {
        print('Username and password cannot be empty');
        // Tambahkan pean untuk kasus ketika username atau password kosong
      }
    } catch (e) {
      print('An error occured: $e');
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
                      onPressed: (){_signIn();},
                      child: Text("Login"),
                  ),
                  SizedBox(height: 20,),
                  RichText(text: TextSpan(
                    text: "Belum punya akun? ",
                    style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                    children: <TextSpan>[
                      TextSpan(
                        text: "daftar disini!",
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = (){ Navigator.pushNamed(context, "/signup");},
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