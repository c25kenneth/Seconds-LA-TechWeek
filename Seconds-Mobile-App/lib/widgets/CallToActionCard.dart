import 'package:flutter/material.dart';

class CallToActionCard extends StatelessWidget {
  final String actionString;  
  const CallToActionCard({Key? key, required this.actionString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
                colors: [Color(0xff53E88B), Color(0xff15BE77)])),
        child: Stack(
          children: [
            Opacity(
              opacity: .5,
              child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/BACKGROUND%202.png?alt=media&token=0d003860-ba2f-4782-a5ee-5d5684cdc244",
                  fit: BoxFit.cover),
            ),
            Image.asset("assets/images/es3tc45l1n342dr3k3ips39ehe-78341bf5ad28d6cf0e6b9e15b412d88d.png", width: 120, height: 120,),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Text(
                  actionString,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
    );
  }
}