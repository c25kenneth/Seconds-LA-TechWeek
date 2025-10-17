import 'package:flutter/material.dart';

class TopBarFb4 extends StatelessWidget {
  final String title;
  final String upperTitle;
  final Function() onTapMenu;
  const TopBarFb4({required this.title, required this.upperTitle, required this.onTapMenu, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: Colors.redAccent,),
              onPressed: onTapMenu,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children:  [
                Text(title,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.normal)),
                Text(upperTitle,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ],
        ),
    );
  }
}