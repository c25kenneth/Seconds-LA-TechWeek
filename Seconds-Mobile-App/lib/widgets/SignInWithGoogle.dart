import 'package:flutter/material.dart';

class GoogleBtn1 extends StatelessWidget {
final Function() onPressed;
  const GoogleBtn1({
required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 54,
        margin: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1.0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/crypto%2Fsearch%20(2).png?alt=media&token=24a918f7-3564-4290-b7e4-08ff54b3c94c",
                width: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text("Continue with Google",
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ],
          ),
          onPressed: onPressed,
        ));
  }
}