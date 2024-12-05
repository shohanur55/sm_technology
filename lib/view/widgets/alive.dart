import 'package:flutter/material.dart';

class CustomAlive extends StatefulWidget {
  final Widget child;

  const CustomAlive({super.key, required this.child});

  @override
  State<CustomAlive> createState() => _CustomAliveState();
}

class _CustomAliveState extends State<CustomAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
