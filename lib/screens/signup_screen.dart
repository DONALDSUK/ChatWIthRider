import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isGoogleSignedIn = false;
  User? _user;
  bool _isAddressValid = false;
  bool _isPhoneValid = false;
  String? _selectedRole;

  Future<void> _signUpWithGoogle() async {
    try {
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        setState(() {
          _isGoogleSignedIn = true;
          _user = user;
        });

        final userDoc = await _firestore.collection("users").doc(user.uid).get();
        if (userDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("이미 가입된 계정입니다.")));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      print("Google 회원가입 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("회원가입 실패: $e")));
    }
  }

  void _validateInputs() {
    setState(() {
      _isAddressValid = _addressController.text.trim().isNotEmpty;
      _isPhoneValid = _phoneController.text.trim().isNotEmpty;
    });
  }

  Future<void> _saveUserData() async {
    _validateInputs();

    if (!_isAddressValid || !_isPhoneValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("주소와 전화번호를 모두 입력하세요.")));
      return;
    }

    if (_user != null) {
      await _firestore.collection("users").doc(_user!.uid).set({
        "uid": _user!.uid,
        "name": _user!.displayName ?? "사용자",
        "email": _user!.email,
        "address": _addressController.text.trim(),
        "phone": _phoneController.text.trim(),
        "role": _selectedRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("회원가입 완료!")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      width: 280,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.blueAccent.shade100, Colors.purpleAccent.shade100],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isValid, TextInputType inputType) {
    return Container(
      width: 280,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          errorText: isValid ? null : "$label을 입력하세요",
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: inputType,
        style: TextStyle(color: Colors.white),
        onChanged: (value) => _validateInputs(),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      width: 280,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white70),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          hint: Text("역할 선택 (손님 / 라이더)", style: TextStyle(color: Colors.white70)),
          dropdownColor: Colors.grey[800],
          items: ["손님", "라이더"].map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role, style: TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2D2D), // 배경색 변경
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isGoogleSignedIn) ...[
                Image.asset(
                  'assets/logo.png',
                  width: 250,
                  height: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Google 계정으로 회원가입",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                _buildGradientButton("Google로 회원가입", _signUpWithGoogle),
              ] else ...[
                Image.asset(
                  'assets/logo.png',
                  width: 250,
                  height: 250,
                ),
                SizedBox(height: 40),
                _buildTextField("주소", _addressController, _isAddressValid, TextInputType.text),
                SizedBox(height: 10),
                _buildTextField("전화번호", _phoneController, _isPhoneValid, TextInputType.phone),
                SizedBox(height: 10),
                _buildDropdown(),
                SizedBox(height: 20),
                _buildGradientButton("회원가입 완료", (_isAddressValid && _isPhoneValid) ? _saveUserData : () {}),
              ],
            ],
          ),
        )
      ),
    );
  }
}
