import 'package:chatrider/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_screen.dart';
import 'orderlist_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(_user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  Widget _buildGradientButton(String text, Color color1, Color color2, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 160,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF2D2D2D), // 배경색 설정
      appBar: AppBar(
        title: Text("ChatWithRider", style: TextStyle(fontSize: 26, color: Colors.white),),
        backgroundColor: Color(0xFF2D2D2D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 250,
                height: 250,
              ),
              SizedBox(height: 10),
              Container(
                width: 320,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.orangeAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async{
                    if (_userData!["role"] == "손님" ) {
                      String myAddress = _userData!["address"];
                      String userId = FirebaseAuth.instance.currentUser!.uid;

                      await FirebaseFirestore.instance.collection("orders").add({
                        "userId": userId,
                        "address": myAddress,
                        "timestamp": FieldValue.serverTimestamp(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("주문이 완료되었습니다!"))
                      );
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("손님만 주문이 가능합니다.")));
                    }
                  },
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    "주문하기",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 사용자 정보 카드
              _userData != null
                  ? Container(
                width: 320,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData!["name"] ?? "사용자 이름",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _userData!["address"] ?? "주소 정보 없음",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _userData!["role"] ?? "라이더 OR 손님",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "전화번호: ${_userData!["phone"] ?? "없음"}",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "이메일: ${_userData!["email"] ?? "없음"}",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              )
                  : CircularProgressIndicator(),

              SizedBox(height: 20),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGradientButton ("주문보기", Colors.lightBlueAccent, Colors.blue, Icons.list, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OrderListScreen()),
                    );
                  }),
                  SizedBox(width: 10),
                  _buildGradientButton("전환하기", Colors.redAccent, Colors.orange, Icons.change_circle, () async {
                    if (_userData!["role"] == "손님" ) {
                      _userData!["role"] = "배달원";

                      await _firestore.collection("users").doc(_user!.uid).update({"role": _userData!["role"]});
                      setState(() {
                        _userData!["role"] = _userData!["role"];
                      });
                    }
                    else{
                      _userData!["role"] = "손님";

                      await _firestore.collection("users").doc(_user!.uid).update({"role": _userData!["role"]});

                      setState(() {
                        _userData!["role"] = _userData!["role"];
                      });
                    }
                  }),
                ],
              ),

              SizedBox(height: 20),


              Container(
                width: 320,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.lightBlueAccent, Colors.blue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen()),
                    );
                  },
                  icon: Icon(Icons.chat, color: Colors.white),
                  label: Text(
                    "채팅하기",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
