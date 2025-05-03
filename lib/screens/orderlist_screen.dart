import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class OrderListScreen extends StatefulWidget {
  final String? userAddress;

  OrderListScreen({this.userAddress});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userRole = "손님"; // 🔥 기본 역할을 "손님"으로 설정

  @override
  void initState() {
    super.initState();
    _fetchUserRole(); // 🔥 사용자의 역할(role) 가져오기
  }

  // 🔥 Firestore에서 로그인한 사용자의 역할 가져오기
  Future<void> _fetchUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _userRole = userDoc["role"]; // 🔥 Firestore에서 가져온 role 저장
        });
      }
    }
  }

  // ✅ Firestore에서 주문 삭제 함수
  Future<void> _deleteOrder(String orderId, String orderUserId, BuildContext context) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    if (currentUserId == orderUserId) {
      await FirebaseFirestore.instance.collection("orders").doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("주문이 삭제되었습니다.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("본인의 주문만 삭제할 수 있습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2D2D),
      appBar: AppBar(
        title: Text("주문보기", style: TextStyle(fontSize: 26, color: Colors.white)),
        backgroundColor: Color(0xFF2D2D2D),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("orders").orderBy("timestamp", descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "데이터를 불러오는 중 오류 발생: ${snapshot.error}",
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "현재 주문이 없습니다.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          List<QueryDocumentSnapshot> orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              String orderId = orders[index].id; // 🔥 주문 ID
              String orderUserId = orders[index]["userId"]; // 🔥 주문한 사용자의 UID
              String orderAddress = orders[index]["address"];

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        orderAddress,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 10),
                    Row(
                      children: [
                        // 🔥 "배달원" 계정만 선택 버튼 활성화
                        ElevatedButton(
                          onPressed: _userRole == "배달원" ? () {
                            print("$orderAddress 선택됨");
                          } : null, // 🔥 손님 계정은 버튼 비활성화
                          child: Text("선택"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _userRole == "배달원" ? Colors.blueAccent : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOrder(orderId, orderUserId, context),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
