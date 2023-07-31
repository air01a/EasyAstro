import 'package:flutter/material.dart'; 


class SearchField {
  late Function(String) callback;
  bool isSearchActive = false;
  FocusNode myFocusNode = FocusNode();
  SearchField();

  void filterActivate() {
    isSearchActive = ! isSearchActive;
    if (isSearchActive) {
      myFocusNode.requestFocus();
    }
  }

  void setCallBack(Function(String) cb) {
    callback = cb;
  }

  Widget buildSearchTextField() {
    if (isSearchActive) {
      

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextField(
          focusNode: myFocusNode,
          decoration: const InputDecoration(
            hintText: 'Enter your search query...',
          ),
          onChanged: (value) {
            // Handle search query submission
            callback(value);
          },
        ),
      );
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }
/*
  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }*/
}