import 'package:flutter/src/foundation/key.dart';
import 'package:graphview/GraphView.dart';

class CustomNode extends Node {
  String _id;
  String _type;

  CustomNode(this._id, this._type) : super.Id(_id); // Use the ID as the Node's key

  // Getter for id
  String get id => _id;

  // Setter for id
  set id(String newId) {
    _id = newId;
    key = newId as ValueKey?; // Update the Node's key when the ID changes
  }

  // Getter for type
  String get type => _type;

  // Setter for type
  set type(String newType) {
    _type = newType;
  }

  @override
  String toString() => 'CustomNode(id: $id, type: $type)';
}