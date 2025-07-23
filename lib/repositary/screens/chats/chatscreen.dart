import 'package:flutter/material.dart';

import '../../../domain/constants/appcolors.dart';
import '../widgets/Uihelper.dart';

class Chatscreen extends StatelessWidget {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        elevation: 0,
        title: Uihelper.CustomText(
            text: "Chats",
            fontsize: 25,
            fontweight: FontWeight.bold,
            fontfamily: "bold",
            context: context),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Uihelper.CustomTextField(
                controller: searchController,
                text: "Search",
                textinputtype: TextInputType.text,
                context: context,
                icondata: Icons.search)
          ],
        ),
      ),
    );
  }
}
