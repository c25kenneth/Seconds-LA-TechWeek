import 'package:flutter/material.dart';

class AppleBtn1 extends StatelessWidget {
  final Function() onPressed;
  const AppleBtn1({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 54,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1.0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/socials%2Fapple-black-logo.png?alt=media&token=c44581fa-6fd2-4ae2-bd85-18bfbe6386d2",
                width: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text("Continue with Apple",
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ],
          ),
          onPressed: onPressed,
        ));
  }
}