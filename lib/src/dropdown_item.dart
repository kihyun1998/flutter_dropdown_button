import 'package:flutter/material.dart';

class DropdownItem<T> {
  const DropdownItem({required this.value, required this.child, this.onTap});

  final T value;
  final Widget child;
  final VoidCallback? onTap;
}
